require "pingpp"
module Spree
  class Gateway::PingppBase < PaymentMethod
    preference :api_key, :string
    #Pingpp.api_key = "YOUR-KEY"

    def provider
      Gateway::PingppProvider.new( self )
    end

    def payment_source_class
      PingppTransaction
    end

    #copy from Gateway
    def sources_by_order(order)
      source_ids = order.payments.where(source_type: payment_source_class.to_s, payment_method_id: self.id).pluck(:source_id).uniq
      payment_source_class.where(id: source_ids)
    end
  end
end
