# frozen_string_literal: true
require 'cash_out/configuration'

require 'active_interaction'
require 'stripe'
require 'cash_out/base'
require 'cash_out/service_base'
require 'cash_out/payments/customer/create'
require 'cash_out/payments/customer/delete'

module CashOut
  extend self

  attr_accessor :configuration

  def configuration
    @configuration ||= Configuration.new
  end

  def reset
    @configuration = Configuration.new
  end

  def configure
    yield(configuration)
    Stripe.api_key = configuration.stripe_secret_key
  end
end

require 'generators/cash_out/templates/cash_out_config'
require 'generators/cash_out/install_generator'

I18n.load_path += Dir['config/locales/en.yml']
