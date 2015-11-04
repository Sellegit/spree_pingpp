Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  put '/checkout/handle_pingpp', :to => 'checkout#handle_pingpp', as: :handle_pingpp, format: :json


end
