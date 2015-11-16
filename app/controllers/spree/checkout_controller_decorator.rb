#encoding: utf-8
module Spree
  CheckoutController.class_eval do
    #before_filter :checkout_hook, :only => [:update]

    # handle all supported billing_integration
    def handle_pingpp
      @pingpp_base_class = Spree::Gateway::PingppBase
      if @order.update_from_params( params, permitted_checkout_attributes, request.headers.env )
        payment_method = get_payment_method(  )
        if payment_method.kind_of?(@pingpp_base_class)
          #more flow detail
          #https://pingxx.com/guidance/products/sdk
          payment_provider = payment_method.provider
          #please try with host 127.0.0.1 instead localhost, or get invalid url http://localhost:3000/...
          #order_path( order, :only_path => false )
          charge = payment_provider.create_charge( @order, spree.order_path( @order, :only_path => false ) )
          render json: charge
        end
      else
        render( :edit ) and return
      end
    end

    private

    def build_payment_params

    end

    #in co@alipay_base_classis {"state"=>"confirm"}
    def get_payment_method(  )
      payment_method_id = params[:order].try(:[],:payments_attributes).try(:first).try(:[],:payment_method_id).to_i

      PaymentMethod.find_by_id(payment_method_id) || @order.pending_payments.first.try(:payment_method)
    end

  end
end
