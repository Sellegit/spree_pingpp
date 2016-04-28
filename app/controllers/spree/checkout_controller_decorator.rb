#encoding: utf-8
module Spree
  CheckoutController.class_eval do
    #before_filter :checkout_hook, :only => [:update]

    # handle all supported billing_integration
    def handle_pingpp
      order = current_order || raise(ActiveRecord::RecordNotFound)
      order.payments.create(amount: order.total,
                            payment_method: payment_method)

      begin
        @pingpp_base_class = Spree::Gateway::PingppBase
        pingpp_channel = params['payment_pingpp_channel']
        payment_method = get_payment_method(  )
        puts "payment_method = #{payment_method.inspect} "
        if payment_method.kind_of?(@pingpp_base_class)
          #more flow detail
          #https://pingxx.com/guidance/products/sdk
          payment_provider = payment_method.provider
          #please try with host 127.0.0.1 instead localhost, or get invalid url http://localhost:3000/...
          #order_path( order, :only_path => false )
          charge = payment_provider.create_charge( @order, pingpp_channel, spree.pingpp_charge_done_path( :only_path => false ) )
          render json: charge
        end
      rescue SocketError
        flash[:error] = Spree.t('flash.sign_server_connection_failed', :scope => 'chinapay')
        redirect_to checkout_state_path(:payment)
      end

    end

    private

    #in co@alipay_base_classis {"state"=>"confirm"}
    def get_payment_method(  )
      @order.unprocessed_payments.first.try(:payment_method)
    end

    def payment_method
      Spree::PaymentMethod.find(params[:payment_method_id])
    end

  end
end
