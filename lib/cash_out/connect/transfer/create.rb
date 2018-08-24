module CashOut
  module Connect
    module Transfer
      class Create < ::CashOut::ServiceBase
        interface :payee, methods: %i(stripe_id)
        integer :amount_to_payout

        def execute
          initiate_transfer
        end

        private

        def initiate_transfer
          Stripe::Transfer.create(*params)
        rescue Stripe::InvalidRequestError,
               Stripe::AuthenticationError,
               Stripe::APIConnectionError,
               Stripe::StripeError => e
          errors.add(:stripe, e.to_s)
          e.json_body
        end

        def params
          # Stripe does not allow negative transfers, so we must change the params accordingly
          amount_to_payout.positive? ? positive_payout_params : negative_payout_params
        end

        def negative_payout_params
          # Makes a transfer from the payee to the platform account for amount owed
          # https://stripe.com/docs/connect/account-debits#transferring-from-a-connected-account
          [
            {
              amount: amount_to_payout.abs,
              currency: "usd",
              description: "",
              destination: platform_stripe_account.id,
              transfer_group: ""
            },
            {
              stripe_account: payee.stripe_id
            }
          ]
        end

        def positive_payout_params
          # Only runs when payout is positive but payout amount > charges
          # Makes a transfer from platform account to payee
          # Platform Stripe Account balance MUST be greater than transfer amount
          [
            {
              amount: amount_to_payout,
              currency: "usd",
              description: "",
              destination: payee.stripe_id,
              transfer_group: ""
            },
            {
              stripe_account: platform_stripe_account.id,
            }
          ]
        end

        def platform_stripe_account
          # Calling retrieve without a param retrieves the platform account
          # In test mode, create charges with 4000 0000 0000 0077 to add funds
          # https://stripe.com/docs/testing#cards-responses
          @platform_stripe_account ||= Stripe::Account.retrieve
        end
      end
    end
  end
end

