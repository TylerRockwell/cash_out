# frozen_string_literal: true
# Config
require 'cash_out/configuration'

# External dependencies
require 'active_interaction'
require 'stripe'

# Core Files
require 'cash_out/base'
require 'cash_out/service_base'

# Other Services
require 'cash_out/charge/create'
require 'cash_out/connect/account/create'
require 'cash_out/connect/account/delete'
require 'cash_out/connect/transfer/create'
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

  def root
    File.dirname __dir__
  end
end

translation_path = [File.join(CashOut.root, 'config', 'locales', 'en.yml')]
I18n.load_path += translation_path

require 'generators/cash_out/templates/cash_out_config'
require 'generators/cash_out/install_generator'
