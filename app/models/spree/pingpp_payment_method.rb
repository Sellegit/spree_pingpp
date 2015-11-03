require "pingpp"
module Spree
  class PingppPaymentMethod < PaymentMethod
    preference :api_key, :string
    #Pingpp.api_key = "YOUR-KEY"

    def auto_capture?
      true
    end



    def cancel( alipay_transaction )
      Pingpp::Charge.retrieve("CHARGE_ID").refunds.create(:description => "Refund Description")
    end



  end
end
