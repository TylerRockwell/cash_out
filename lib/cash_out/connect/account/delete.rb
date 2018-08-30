module CashOut
  module Connect
    module Account
      class Delete < ::CashOut::ServiceBase
        interface :user, methods: %i(stripe_id save valid?)

        def execute
          delete_account
          user.stripe_id = nil
          validate_and_save(user)
        end

        private

        def delete_account
          Stripe::Account.retrieve(user.stripe_id).delete
        rescue *STRIPE_ERRORS => e
          errors.add(:stripe, e.to_s)
        end
      end
    end
  end
end
