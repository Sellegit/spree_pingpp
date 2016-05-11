Rails.application.routes.draw do
  # Add your extension routes here
  post '/checkout/handle_pingpp', :to => 'pingpp_checkout#handle_pingpp', as: :handle_pingpp, format: :json

  # alipay get,  upacp_pc post
  match '/pingpp/charge_done', :to=> 'pingpp_checkout#charge_done', as: :pingpp_charge_done,  via: [:get, :post]

  # pingpp_wx_get_open_id_path
  get '/pingpp/wx_get_open_id', :to => 'pingpp_checkout#wx_get_open_id', as: :pingpp_wx_get_open_id

  post '/pingpp/charge_notify', :to=> 'pingpp_checkout#charge_notify', as: :pingpp_charge_notify
end
