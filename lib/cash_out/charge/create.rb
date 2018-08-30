module CashOut
  module Charge
    class Create < ::CashOut::ServiceBase
      interface :payor, methods: %i(stripe_id)
      interface :payee, methods: %i(stripe_id), default: nil
      integer :amount_to_charge
      integer :amount_to_payout, default: 0

      validate :charges_are_positive

      def execute
        create_charge
      end

      private

      def create_charge
        # Stripe won't let you create a destination charge if the payout exceeds the charges
        payout_less_than_charge? ? destination_charge : standalone_charge
      end

      def payout_less_than_charge?
        amount_to_payout.positive? && amount_to_payout < amount_to_charge
      end

      def destination_charge
        # This is what we should do in most cases
        # amount_to_charge is charged to payor
        # amount_to_payout goes to payee
        # Remainder is kept in company Stripe account
        # https://stripe.com/docs/connect/destination-charges#collecting-platform-fees
        return errors.add(:stripe, I18n.t('cash_out.charge.no_payee')) unless payee
        charge_payor(destination_charge_params)
      end

      def standalone_charge
        # When dealing with a negative payout, we must create the charge and transfer separately
        charge_payor(standalone_charge_params)
        initiate_transfer
      end

      def initiate_transfer
        CashOut::Connect::Transfer::Create.run(payee: payee, amount_to_payout: amount_to_payout)
      end

      def charge_payor(*args)
        Stripe::Charge.create(*args)
      rescue *STRIPE_ERRORS => e
        errors.add(:stripe, e.to_s)
        e.json_body
      end

      def standalone_charge_params
        # Charges the payor the total amount owed
        {
          amount: amount_to_charge,
          currency: "usd",
          description: "",
          customer: payor.stripe_id
        }
      end

      def destination_charge_params
        # Charges the payor the total amount owed
        # Sends payout amount to payee
        {
          amount: amount_to_charge,
          currency: "usd",
          description: "",
          customer: payor.stripe_id,
          destination: {
            account: payee.stripe_id,
            amount: amount_to_payout
          }
        }
      end

      def charges_are_positive
       # Charge will fail if balance due is $0.00
       # Charge should never be negative
       unless amount_to_charge.positive?
         errors.add(:stripe,I18n.t('cash_out.charge.invalid_charge_amount'))
       end
      end
    end
  end
end
