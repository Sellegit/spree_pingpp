require "pingpp"
module Spree
  class PingppEventHandler
    attr_accessor :event, :response_body, :status
    def initialize( event )
      self.event = event
      status = 500
      response_body = '' # 可自定义

    end

    def perform
      if event['type'].nil?
        response_body = 'missing event type'
      elsif event['type'] == 'charge.succeeded'
        charge_succeeded
        status = 200
        response_body = 'ok'
      elsif event['object'] == 'refund.succeeded'
        # 开发者在此处加入对退款异步通知的处理代码
        status = 200
        response_body = 'ok'
      else
        response_body = 'unkonwn event type'
      end
      return status, response_body
    end

    def charge_succeeded
      charge = event['data']['object']
      payment = Spree::Payment.find_by(response_code: charge['id'])
      if payment.present? && !payment.completed?
        payment.transaction do
          payment.started_processing!
          payment.complete!
          payment.order.next! until payment.order.completed?
        end
      end
    end
  end
end
