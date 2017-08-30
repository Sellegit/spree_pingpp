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

window.SpreePingppPay = {}

Spree.ready ($) ->
	Spree.SpreePingpp =
		updateSaveAndContinueVisibility: ()->
			if this.isButtonHidden()
				$(this).trigger('hideSaveAndContinue')
			else 
				$(this).trigger('showSaveAndContinue')
		isButtonHidden:  ()->
			paymentMethod = this.checkedPaymentMethod();
			(!$('#use_existing_card_yes:checked').length && window.SpreePingppPay.paymentMethodID && paymentMethod.val() == window.SpreePingppPay.paymentMethodID);
		checkedPaymentMethod: ()->
			$('div[data-hook="checkout_payment_step"] input[type="radio"][name="order[payments_attributes][][payment_method_id]"]:checked');
		hideSaveAndContinue: ()->
			$("#checkout_form_payment [data-hook=buttons]").hide();
		showSaveAndContinue: ()->
			$("#checkout_form_payment [data-hook=buttons]").show();

	Spree.SpreePingpp.updateSaveAndContinueVisibility()		
	$('div[data-hook="checkout_payment_step"] input[type="radio"]').click ->
		if this.value == SpreePingppPay.paymentMethodID
			$("#checkout_form_payment [data-hook=buttons]").hide()

