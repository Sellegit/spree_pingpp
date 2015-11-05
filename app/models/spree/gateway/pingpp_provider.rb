require "pingpp"
module Spree
  class Gateway::PingppProvider
    attr_accessor :payment_method

    def initialize( payment_method )
      self.payment_method = payment_method
      setup_api_key( payment_method.preferred_api_key )
    end

    def setup_api_key( key )
      Pingpp.api_key = key
    end


    def create_charge( order, success_url )
      params = {
        :order_no => order.number,
        :amount   => (order.total * 100).to_i,                     # in cent
        :subject  => "订单编号 : #{order.number}",
        :body     =>  order.products.collect(&:name).to_s,  #String(400)
        :channel  => "alipay_pc_direct",
        :currency => "cny",
        :client_ip=> get_client_ip,
        :app => {:id => payment_method.preferred_app_key},
        :extra => {
        #  :alipay_pc_direct=>{
            :success_url => success_url
        #  }
        }
      }
      charge = Pingpp::Charge.create( params  )
      # store charge "id": "ch_Hm5uTSifDOuTy9iLeLPSurrD",

    end

    def cancel( order )
      Pingpp::Charge.retrieve("CHARGE_ID").refunds.create(:description => "Refund Description")
    end


    def get_pingpp_transaction( order )
      payment_method.sources_by_order( order ).first
    end

    def get_client_ip
      "127.0.0.1"
    end
  end
end
