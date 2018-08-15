module CashOut
  module Payments
    module Customer
      class Create < ::CashOut::ServiceBase
        object :user
        string :stripe_token, default: nil

        validate :no_existing_stripe_customer

        def execute
          customer = create_stripe_customer
          user.stripe_id = customer["id"] if customer.is_a?(Stripe::Customer)
          validate_and_save(user)
        end

        private

        def create_stripe_customer
          Stripe::Customer.create(source: stripe_token)
        rescue Stripe::InvalidRequestError,
               Stripe::AuthenticationError,
               Stripe::APIConnectionError,
               Stripe::StripeError => e
          if e.class == Stripe::CardError
            errors.add(:stripe, "There was a problem with your card.")
          else
            errors.add(:stripe, e.to_s)
          end
        end

        def no_existing_stripe_customer
          errors.add(:stripe, "Account already exists") if user.stripe_id.present?
        end
      end
    end
  end
end
