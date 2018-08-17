module CashOut
  module Payments
    module Customer
      class Delete < ::CashOut::ServiceBase
        object :user

        def execute
          delete_customer
          user.stripe_id = nil
          validate_and_save(user)
        end

        private

        def delete_customer
          Stripe::Customer.retrieve(user.stripe_id).delete
        rescue *STRIPE_ERRORS => e
          errors.add(:stripe, e.to_s)
        end
      end
    end
  end
end
