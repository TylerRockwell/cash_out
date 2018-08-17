require 'rails/generators'

module CashOut
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)
    desc "Generates configuration file for CashOut"

    def create_initializer_file
      template "cash_out_config.rb", "config/initializers/cash_out.rb"
    end
  end
end
