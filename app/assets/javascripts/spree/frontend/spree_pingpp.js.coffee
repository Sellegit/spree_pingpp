//= require 'pingpp-pc'
//= require 'pingpp'

$(document).ready ->
  $('.pingpp_channel').click ->
    $.ajax
      type: 'patch'
      url: '/checkout/handle_pingpp'
      data: payment_method_id: $(this).data('payment-method-id')
      success: (charge) ->
        if charge.redirect_to
          location.href = charge.redirect_to
        else
          pingppPc.createPayment charge, (result, err) ->
            if result == 'success'
            else if result == 'fail'
              return pingpp.createPayment(charge, (result, err) ->
                if result == 'success'
                else if result == 'fail'
                else if result == 'cancel'
                  return alert(err)
                return
              )
            else if result == 'cancel'
              return alert(err)
            return
    false
  return
