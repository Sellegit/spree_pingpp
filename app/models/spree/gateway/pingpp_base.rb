require "pingpp"
module Spree
  class Gateway::PingppBase < Gateway
    preference :api_key, :string
    preference :app_key, :string
    preference :channels, :string
    #Pingpp.api_key = "YOUR-KEY"

    def auto_capture?
      true
    end

    def provider_class
      self.class
    end
    
    def provider
      Gateway::PingppProvider.new( self )
    end

    def source_required?
      true
    end

    def available_channels
      self.preferred_channels.split(',')
    end

    def method_type
      'pingpp'
    end

    def purchase(amount, pingpp, gateway_options={})
      Class.new do
        define_method(:success?) { pingpp.status == 'success' }

        def authorization; nil; end
      end.new
    end

  end
end
