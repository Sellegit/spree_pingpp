require 'webrick'
require 'json'
require 'OpenSSL'
require 'base64'
require 'spree/gateway/pingpp_provider'
#inspired by https://github.com/spree-contrib/spree_skrill
class PingppCheckoutController < BaseController
  #fixes Action::Controller::InvalidAuthenticityToken error on alipay_notify
  skip_before_action :verify_authenticity_token
  skip_before_action :require_login

  before_action :valide_order, :only => [:handle_pingpp, :wx_get_open_id]

  skip_before_action :ensure_valid_state, :only => [:wx_get_open_id]

  def handle_pingpp
    case payment_method.preferred_channels
    when 'wx_pub'
      url = Pingpp::WxPubOauth.create_oauth_url_for_code(payment_method.preferred_wx_app_id, pingpp_wx_get_open_id_url)
      @charge = {:redirect_to => url}.to_json
    else
      @order.payments.create(amount: @order.total,
      payment_method: payment_method)
      begin
        payment_provider = payment_method.provider
        @charge = payment_provider.create_charge( @order, payment_method.preferred_channels, pingpp_charge_done_path( :only_path => false )).to_json
      rescue SocketError
        flash[:error] = Spree.t('flash.sign_server_connection_failed', :scope => 'chinapay')
        redirect_to checkout_state_path(:payment)
      end
    end
    render layout: false
  end

  def wx_get_open_id
    payment_method = Spree::PaymentMethod.find_by(:type => 'Spree::Gateway::PingppWeixin')
    open_id, error = Pingpp::WxPubOauth.get_openid(payment_method.preferred_wx_app_id, payment_method.preferred_wx_app_secret, params['code'])
    @order.payments.create(amount: @order.total,
    payment_method: payment_method)
    payment_provider = payment_method.provider
    @charge = payment_provider.create_charge( @order, payment_method.preferred_channels, pingpp_charge_done_path( :only_path => false ), open_id)
    render layout: false
  end

  # 验证 webhooks 签名
  def verify_signature(raw_data, signature, pub_key_path)
    rsa_public_key = OpenSSL::PKey.read(File.read(pub_key_path))
    rsa_public_key.verify(OpenSSL::Digest::SHA256.new, Base64.decode64(signature), raw_data)
  end

  # success url
  def charge_done
    #alipay, get, "result"=>"success", "out_trade_no"=>"R677576938"
    #upacp_pc, post, "orderId"=>"R677576938", "respMsg"=>"success"
    order = retrieve_order
    redirect_to order_path( order )
  end

  def charge_notify
    headers = get_headers(request.headers)
    p headers
    # 签名在头部信息的 x-pingplusplus-signature 字段
    if !headers.has_key?(:x_pingplusplus_signature)
      response.status = 401
      return
    end
    # 原始请求数据是待验签数据，请根据实际情况获取
    raw_data = request.body.read
    signature = headers[:x_pingplusplus_signature]
    # 请从 https://dashboard.pingxx.com 获取「Ping++ 公钥」
    pub_key_path = Rails.root.join('pingpp_rsa_public_key.pem')

    if verify_signature(raw_data, signature, pub_key_path)
      status = 400
      response_body = ''
      begin
        # 根据你的逻辑处理 params
        if params['type'].nil?
          response_body = 'Event 对象中缺少 type 字段'
        elsif params['type'] == 'charge.succeeded'
          confirm
          # 开发者在此处加入对支付异步通知的处理代码
          status = 200
          response_body = 'OK'
        elsif params['type'] == 'refund.succeeded'
          # 开发者在此处加入对退款异步通知的处理代码
          status = 200
          response_body = 'OK'
        else
          response_body = '未知 Event 类型'
        end
      rescue JSON::ParserError
        response_body = 'JSON 解析失败'
      end
      response.body = response_body
      response['Content-Type'] = 'text/plain; charset=utf-8'
      response.status = status # 2XX 表示成功接收
    else
      response.status = 403
    end
    render :json => response.body, :status => response.status
  end

  def confirm
    order = pingpp_order || raise(ActiveRecord::RecordNotFound)
    source = Spree::PingppCheckout.create(status: 'success')
    order.payments.each do |payment|
      payment.source = source
      payment.save
    end
    order.next
  end

  private

  def payment_method
    Spree::PaymentMethod.find(params[:payment_method_id])
  end

  def valide_order
    @order = current_order || raise(ActiveRecord::RecordNotFound)
  end

  def retrieve_order
    order_number = ( params["orderId"] || params["out_trade_no"] )
    Spree::Order.find_by_number!(order_number)
  end

  def pingpp_order
    order_number = params[:data][:object][:order_no]
    Spree::Order.find_by_number!(order_number)
  end

  # 格式化 key
  def get_headers(original_headers)
    new_headers = {}
    if !original_headers.respond_to?("each")
      return nil
    end

    original_headers.each do |k, h|
      if k.is_a?(Symbol)
        k = k.to_s
      end
      k = k[0, 5] == 'HTTP_' ? k[5..-1] : k
      new_k = k.gsub(/-/, '_').downcase.to_sym

      header = nil
      if h.is_a?(Array) && h.length > 0
        header = h[0]
      elsif h.is_a?(String)
        header = h
      end

      if header
        new_headers[new_k] = header
      end
    end

    return new_headers
  end

end
