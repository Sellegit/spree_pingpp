//= require 'pingpp-pc'
//= require 'pingpp'
Spree.routes.handle_pingpp = Spree.pathFor('checkout/handle_pingpp')

Spree.ready ($) ->
  Spree.onPingppPayment = () ->
    if ($ '#checkout_form_payment').is('*')
      $('.pingpp_channel').click ->
        $.ajax
          type: 'patch'
          url: Spree.routes.handle_pingpp
          data: {
            payment_method_id: $(this).data('payment-method-id')
          }
          success: (charge)->
            if charge.redirect_to
              location.href = charge.redirect_to
            else
              pingppPc.createPayment charge, (result, err) ->
                if result == "success"

                else if result == "fail"
                  pingpp.createPayment charge, (result, err) ->
                    if result == "success"
                    else if result == "fail"
                    else if result == "cancel"
                      alert(err)
                else if result == "cancel"
                  alert(err)
        false

  Spree.onPingppPayment()
