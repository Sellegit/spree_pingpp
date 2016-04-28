#encoding: utf-8
require 'spree/gateway/pingpp_provider'
module Spree
  CheckoutController.class_eval do
    #before_filter :checkout_hook, :only => [:update]
    before_action :valide_order, :only => [:handle_pingpp]
    skip_before_action :ensure_valid_state, :only => [:wx_get_open_id]
    # handle all supported billing_integration
    def handle_pingpp
      case payment_method.preferred_channels
      when 'wx_pub'
        url = Pingpp::WxPubOauth.create_oauth_url_for_code(payment_method.preferred_wx_app_id, spree.pingpp_wx_get_open_id_url)
        render :json => {:redirect_to => url}
      else
        @order.payments.create(amount: @order.total,
        payment_method: payment_method)
        begin
          payment_provider = payment_method.provider
          charge = payment_provider.create_charge( @order, payment_method.preferred_channels, spree.pingpp_charge_done_path( :only_path => false ) )
          render json: charge
        rescue SocketError
          flash[:error] = Spree.t('flash.sign_server_connection_failed', :scope => 'chinapay')
          redirect_to checkout_state_path(:payment)
        end
      end
    end

    def wx_get_open_id
      payment_method = Spree::PaymentMethod.find_by(:type => 'Spree::Gateway::PingppWeixin')
      open_id, error = Pingpp::WxPubOauth.get_openid(payment_method.preferred_wx_app_id, payment_method.preferred_wx_app_secret, params['code'])
      @order.payments.create(amount: @order.total,
      payment_method: payment_method)
      payment_provider = payment_method.provider
      @charge = payment_provider.create_charge( @order, payment_method.preferred_channels, spree.pingpp_charge_done_path( :only_path => false ), open_id)
      render layout: false
    end



    private

    def payment_method
      Spree::PaymentMethod.find(params[:payment_method_id])
    end

    def valide_order
      @order = current_order || raise(ActiveRecord::RecordNotFound)
    end

  end
end
