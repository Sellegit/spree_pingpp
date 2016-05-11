//= require 'pingpp-pc'
//= require 'pingpp'

function chargeDone(charge) {
  if (charge.redirect_to) {
    return location.href = charge.redirect_to;
  } else {
    return pingppPc.createPayment(charge, function(result, err) {
      if (result === 'success') {

      } else if (result === 'fail') {
        return pingpp.createPayment(charge, function(result, err) {
          if (result === 'success') {

          } else if (result === 'fail') {

          } else if (result === 'cancel') {
            return alert(err);
          }
        });
      } else if (result === 'cancel') {
        return alert(err);
      }
    });
  }
}
