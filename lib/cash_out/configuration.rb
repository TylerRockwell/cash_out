module CashOut
  class Configuration
    attr_accessor :stripe_publishable_key, :stripe_secret_key, :stripe_api_key

    def initialize
      @stripe_publishable_key = nil
      @stripe_secret_key = nil
    end
  end
end
