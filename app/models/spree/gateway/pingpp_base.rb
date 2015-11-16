require "pingpp"
module Spree
  class Gateway::PingppBase < PaymentMethod
    preference :api_key, :string
    preference :app_key, :string
    #Pingpp.api_key = "YOUR-KEY"

    def provider
      Gateway::PingppProvider.new( self )
    end

    def source_required?
      false
    end
  end
end
