module CashOut
  module Payments
    module Customer
      class Create < ::CashOut::ServiceBase
        interface :user, methods: %i(stripe_id valid? save)
        string :stripe_token, default: nil

        validate :customer_is_nil

        def execute
          customer = create_stripe_customer
          user.stripe_id = customer["id"] if customer.is_a?(Stripe::Customer)
          validate_and_save(user)
        end

        private

        def create_stripe_customer
          Stripe::Customer.create(source: stripe_token)

        rescue *STRIPE_ERRORS => e
          if e.class == Stripe::CardError
            errors.add(:stripe, I18n.t('cash_out.customer.invalid_card'))
          else
            errors.add(:stripe, e.to_s)
          end
        end

        def customer_is_nil
          unless user.stripe_id.blank?
            errors.add(:stripe, I18n.t('cash_out.customer.account_already_exists'))
          end
        end
      end
    end
  end
end
