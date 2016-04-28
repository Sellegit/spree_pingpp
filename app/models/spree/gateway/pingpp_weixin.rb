require "pingpp"
module Spree
  class Gateway::PingppWeixin < Gateway::PingppBase
    preference :wx_app_id, :string #微信 appid
    preference :wx_app_secret, :string #微信 appsecret

  end
end
