module CashOut
  module Connect
    module Account
      class Create < ::CashOut::ServiceBase
        interface :user, methods: %i(stripe_id valid? save date_of_birth first_name last_name)
        string :external_account_token
        string :ip_address
        string :legal_entity_type
        string :ssn_last_4
        boolean :stripe_terms_accepted, default: false
        hash :legal_entity_address do
          string :line1
          string :line2, default: ""
          string :city
          string :state
          string :country
          string :postal_code
        end

        validates :stripe_terms_accepted, presence: true
        validate :no_existing_stripe_account, :legal_entity_must_be_present

        def execute
          account = create_stripe_account
          user.stripe_id = account["id"] if account.is_a?(Stripe::Account)
          validate_and_save(user)
        end

        private

        def create_stripe_account
          Stripe::Account.create(stripe_account_params)
        rescue *STRIPE_ERRORS => e
          errors.add(:stripe, e.to_s)
        end

        def stripe_account_params
          {
            type: "custom",
            country: "US",
            tos_acceptance: {
              date: Time.current.to_i,
              ip: ip_address,
            },
            payout_schedule: {
              delay_days: 2,
              interval: "daily"
            },
            debit_negative_balances: true,
            legal_entity: legal_entity_params,
            external_account: external_account_token
          }
        end

        def legal_entity_params
          {
            type: legal_entity_type,
            first_name: user.first_name,
            last_name: user.last_name,
            ssn_last_4: ssn_last_4,
            dob: {
              day: user.date_of_birth.day,
              month: user.date_of_birth.month,
              year: user.date_of_birth.year,
            },
            address: {
              line1: legal_entity_address[:line1],
              line2: legal_entity_address[:line2],
              city: legal_entity_address[:city],
              state: legal_entity_address[:state],
              country: legal_entity_address[:country],
              postal_code: legal_entity_address[:postal_code]
            }
          }
        end

        def no_existing_stripe_account
          errors.add(:stripe, I18n.t('cash_out.connect.account_already_exists')) if user.stripe_id.present?
        end

        def legal_entity_must_be_present
          missing_fields.each { |mf| errors.add(mf, I18n.t('cash_out.connect.is_required')) }
        end

        def missing_fields
          legal_entity_address.except(:line2).map do |key, value|
            key.to_sym if value.empty?
          end.compact
        end
      end
    end
  end
end
