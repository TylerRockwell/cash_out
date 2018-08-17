class CashOut::ServiceBase < ActiveInteraction::Base
  STRIPE_ERRORS = [
    Stripe::InvalidRequestError,
    Stripe::AuthenticationError,
    Stripe::APIConnectionError,
    Stripe::StripeError
  ].freeze

  def validate_and_save(model_object)
    unless model_object.save
      errors.merge!(model_object.errors)
    end
    model_object
  end

  def success_message
    I18n.t('cash_out.service.success')
  end

  def failure_message
    I18n.t('cash_out.service.failure')
  end

  def failure_status
    422
  end
end
