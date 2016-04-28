require "pingpp"
module Spree
  class Gateway::PingppProvider
    PingppPcChannelEnum = Struct.new(:alipay_pc_direct, :upacp_pc)[ 'alipay_pc_direct', 'upacp_pc']
    PingppWeixinChannelEnum = Struct.new(:wx_pub)['wx_pub']
    attr_accessor :payment_method

    def initialize( payment_method )
      self.payment_method = payment_method
      setup_api_key( payment_method.preferred_api_key )
    end

    def setup_api_key( key )
      Pingpp.api_key = key
    end


    def create_charge( order, channel, success_url, open_id=nil )
      amount = payment_method.preferred_test_mode ? 1 : (order.total * 100).to_i
      channel ||= PingppPcChannelEnum.alipay_pc_direct
      params = {
        :order_no => order.number,
        :amount   => amount,                     # in cent
        :subject  => "Order : #{order.number}",
        :body     => order.products.collect(&:name).to_s,  #String(400)
        :channel  => channel,
        :currency => "cny",
        :client_ip=> get_client_ip,
        :app => { :id => payment_method.preferred_app_key },
      }
      extra_alipay_params= {
        :extra => {
          # alipay
          :success_url => success_url #
        }
      }
      extra_upacp_params= {
        :extra => {
          # upacp
          :result_url => success_url #
        }
      }
      extra_wx_pub_params={
        :extra => {
          :open_id => open_id
        }
      }

      case channel
      when PingppPcChannelEnum.alipay_pc_direct
        params.merge! extra_alipay_params
      when PingppPcChannelEnum.upacp_pc
        params.merge! extra_upacp_params
      when PingppWeixinChannelEnum.wx_pub
        params.merge! extra_wx_pub_params
      end

      charge = Pingpp::Charge.create( params  )
      # store charge "id": "ch_Hm5uTSifDOuTy9iLeLPSurrD",
      payment = get_payment_by_order( order )
      payment.update_attribute( :response_code, charge['id'] )
      charge
    end

    def cancel( order )
      Pingpp::Charge.retrieve("CHARGE_ID").refunds.create(:description => "Refund Description")
    end

    def get_payment_by_order( order )
      order.unprocessed_payments.first
    end

    def get_client_ip
      '127.0.0.1'
    end
  end
end
