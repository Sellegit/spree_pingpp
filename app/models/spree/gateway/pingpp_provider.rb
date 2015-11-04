require "pingpp"
module Spree
  class Gateway::PingppProvider
    attr_accessor :payment_method

    def initialize( payment_method )
      self.payment_method = payment_method
      setup_api_key( payment_method.api_key )
    end

    def setup_api_key( key )
      Pingpp.api_key = "sk_test_ibbTe5jLGCi5rzfH4OqPW9KC"
    end


    def create_charge( order )
      charge = Pingpp::Charge.create(
       :order_no => order.number,
       :amount   => order.total,
       :subject  => "订单编号 : #{order.number}",
       :body     =>  order.products.collect(&:name).to_s,  #String(400)
       :channel  => "alipay",
       :currency => "cny",
       :client_ip=> get_client_ip,
       :app => {:id => "app_1Gqj58ynP0mHeX1q"},
       :extra => {
         :alipay_pc_direct=>{
           :success_url => spree.order_path( order, :only_path => false ) 
         }
       }
      )
      # store charge "id": "ch_Hm5uTSifDOuTy9iLeLPSurrD",

    end

    def cancel( alipay_transaction )
      Pingpp::Charge.retrieve("CHARGE_ID").refunds.create(:description => "Refund Description")
    end


    def get_client_ip
      "127.0.0.1"
    end
  end
end
