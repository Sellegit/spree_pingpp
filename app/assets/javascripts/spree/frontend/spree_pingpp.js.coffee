//= require 'pingpp-pc'
Spree.routes.handle_pingpp = Spree.pathFor('checkout/handle_pingpp')

Spree.ready ($) ->
  Spree.onPingppPayment = () ->
    if ($ '#checkout_form_payment').is('*')
      $('.pingpp_channel').click ->
        $.ajax
          type: 'patch'
          url: Spree.routes.handle_pingpp
          data: $('#checkout_form_payment').serialize() + "&payment_pingpp_channel=" + $(this).data('channel') 
          success: (charge)->
            pingppPc.createPayment charge, (result, err) ->
              if result == "success"

              else if result == "fail"
                alert(err)
              else if result == "cancel"
                alert(err)
        false

  Spree.onPingppPayment()
