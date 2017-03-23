(function(KlarnaGateway, $) {
  $.fn.klarnaCredit = function(options) {
    var settings = $.extend({
      paymentChangedElements: $('input[name="order[payments_attributes][][payment_method_id]"]'),
      paymentId: Spree.url(Spree.pathFor("/klarna/session")),
      sessionUrl: $(this).data('payment-method-id'),
      submitButton: $('form.edit_order :submit'),
      authorizationToken: $('#klarna_authorization_token', this),
    }, options);

    // Get a session from the backend and load the form
    function initSession() {
      Spree.ajax({
        method: 'POST',
        url: settings.sessionUrl,
        data: {klarna_payment_method_id: settings.paymentId}
      }).success(function(response) {
        if (response.token === null) {
          window.console && console.log("[Klarna Credit] received empty token:", response)
          displayError();
          return;
        }
        settings.clientToken = response.token
        console.log(localStorageAvailable());
        if (localStorageAvailable()) {
          localStorage.klarnaOrderChecksum = response.checksum;
        }
        Klarna.Credit.init ({
          client_token: response.token
        });
        if (klarnaSelected()) {
          loadKlarnaForm();
        }
      }).error(function(response) {
        window.console && console.log("[Klarna Credit] received erroneous server response:", response);
        displayError();
      });
    }

    function displayError() {
      $('.klarna_error').show();
      $('#klarna_container').hide();
    }

    // Loads the Klarna Form
    function loadKlarnaForm() {
      if (!settings.clientToken) {
        return;
      }

      Klarna.Credit.load ({
        container: "#klarna_container"
      }, function(res) {
        if (res.show_form) {
          settings.showForm = res.show_form;
        } else {
          console.log(res)
        }
      });
    }

    // Try to authorize
    function authorize(approved, notApproved) {
      // First get the current, serialized order
      Spree.ajax({
        method: 'GET',
        url: Spree.url(Spree.pathFor("/klarna/session/order_addresses")),
        dataType: 'json',
        data: {klarna_payment_method_id: settings.paymentId}
      }).done(function(result) {
        if (localStorageAvailable()) {
          localStorage.klarnaOrderTimestamp = new Date();
        }
        Klarna.Credit.authorize(result, function(res) {
          if (res.approved === true) {
            settings.authorizationToken.val(res.authorization_token);
            approved(res)
          } else {
            notApproved(res)
          }
        });
      });
    }

    function klarnaSelected() {
      return settings.paymentChangedElements.filter(":checked").val() == settings.paymentId;
    };

    // Revert Spree's disableSaveOnClick when authorization is denied
    function enableSaveOnClick() {
      $('#checkout_form_payment').find(':submit, :image').attr('disabled', false).addClass('primary').addClass('disabled')
    };

    // see https://gist.github.com/paulirish/5558557
    function localStorageAvailable() {
      var mod = "test";
      try {
        localStorage.setItem(mod, mod);
        localStorage.removeItem(mod);
        return true;
      } catch(e) {
        return false;
      }
    };

    settings.paymentChangedElements.on('change', function(e) {
      // check if Klarna Credit is selected
      if (klarnaSelected()) {
        loadKlarnaForm();
      }
    });

    // Hook into submit and authorize the payment first
    $('#checkout_form_payment').on('submit', function (e) {
      var form = this;
      if (klarnaSelected()) {
        e.preventDefault();
        authorize(function (result) {
          form.submit();
        }, function(result) {
          enableSaveOnClick();
        });
      }
    });

    initSession();
    return this;
  }

  // Reauthorization step before order confirmation.
  //
  // Call this on the confirmation page. It will hook into the form submit
  // and decide whether a reauth is necessary.
  $.fn.klarnaReauthorize = function(options) {
    var settings = $.extend({
      submitButton: $('form.edit_order :submit'),
      sessionUrl: Spree.url("/klarna/session"),
      paymentUrl: Spree.url("/checkout/payment"),
      loader: $('<div class="klarna-loader"></div>')
    }, options);

    if (settings.submitButton) {
      settings.submitButton.attr('disabled', true).removeClass('primary').addClass('gray');
      settings.submitButton.after(settings.loader);
    }

    function updateSession(response) {
      return $.ajax({
        method: 'POST',
        url: settings.updateSessionUrl,
        dataType: 'json',
        data: {token: response.authorization_token}
      }).done(function() {
        if (response.approved) {
          settings.submitButton.attr('disabled', false).addClass('primary').removeClass('gray');
          settings.loader.hide();
        } else {
          window.location.assign(settings.paymentUrl)
        }
      });
    }

    // Get a session from the backend and load the form
    function getSession() {
      if (settings.clientToken) {
        return;
      }
      $.ajax({
        method: 'GET',
        url: settings.sessionUrl,
        dataType: 'json'
      }).done(function(response) {
        if (response.status) {
          Klarna.Credit.init ({
            client_token: response.token
          });

          delete response.data.merchant_urls;

          Klarna.Credit.reauthorize(response.data, updateSession);
        } else {
          window.location.assign(settings.paymentUrl)
        }
      });
    }

    getSession();
  }

  KlarnaGateway.loadSdk = function(w, d, clb) {
    var url = 'https://credit.klarnacdn.net/lib/v1/api.js';
    n = d.createElement('script');
    c = d.getElementById('klarna­credit­lib­x');
    n.async = !0;
    n.src = url + '?' + (new Date ()).getTime();
    c.parentNode.replaceChild(n, c);
    n.onload = clb;
  }
}(window.KlarnaGateway = window.KlarnaGateway || {}, jQuery));
