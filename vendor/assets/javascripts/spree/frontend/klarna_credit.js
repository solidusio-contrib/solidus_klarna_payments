"use strict";
(function(KlarnaGateway, $) {
  $.fn.klarnaAuthorize = function(options) {
    var settings = $.extend({
      authorizationToken: $("#klarna_authorization_token", this),
      form: $("#checkout_form_payment"),
      paymentChangedElements: $("input[name=\"order[payments_attributes][][payment_method_id]\"]"),
      paymentId: $(this).data("payment-method-id"),
      sessionUrl: Spree.url(Spree.pathFor("/klarna/session")),
      submitButton: $("form.edit_order :submit")
    }, options);

    // Get a session from the backend and load the form
    function initSession() {

      // Try to create a new session in the backend
      Spree.ajax({
        method: "POST",
        url: settings.sessionUrl,
        data: {klarna_payment_method_id: settings.paymentId}
      }).success(function(response) {
        if (response.token === null) {
          window.console && console.log("[Klarna Credit] received empty token:", response);
          displayError();
          return;
        }
        settings.clientToken = response.token;
        if (localStorageAvailable()) {

          // Store the checksum of the order. If the order does not change we don"t
          // need to reauthorize in the end.
          localStorage.klarnaOrderChecksum = response.checksum;
        }

        // Initialize the Klarna Credit session in the frontend
        Klarna.Credit.init ({
          client_token: response.token
        });

        // Only load the iframe when Klarna is selected
        if (klarnaSelected()) {
          loadKlarnaForm();
        }
      }).error(function(response) {
        window.console && console.log("[Klarna Credit] received erroneous server response:", response);
        displayError();
      });
    }

    function displayError() {
      $(".klarna_error").show();
      $("#klarna_container").hide();
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
          window.console && console.log(res);
        }
      });
    }

    // Try to authorize
    function authorize(approved, notApproved) {
      // First get the current, serialized order
      Spree.ajax({
        method: "GET",
        url: Spree.url(Spree.pathFor("/klarna/session/order_addresses")),
        dataType: "json",
        data: {klarna_payment_method_id: settings.paymentId}
      }).done(function(result) {
        if (localStorageAvailable()) {
          localStorage.klarnaOrderTimestamp = new Date();
        }
        Klarna.Credit.authorize(result, function(res) {
          if (res.approved === true) {
            settings.authorizationToken.val(res.authorization_token);
            approved(res);
          } else {
            notApproved(res);
          }
        });
      });
    }

    function klarnaSelected() {
      return settings.paymentChangedElements.filter(":checked").val() === settings.paymentId.toString();
    }

    // Revert Spree"s disableSaveOnClick when authorization is denied
    function enableSaveOnClick() {
      $("#checkout_form_payment").find(":submit, :image").attr("disabled", false).addClass("primary").addClass("disabled");
    }

    // Check whether Klarna is selected and load the form
    settings.paymentChangedElements.on("change", function() {
      // check if Klarna Credit is selected
      if (klarnaSelected()) {
        loadKlarnaForm();
      }
    });

    // Hook into submit and authorize the payment first
    settings.form.on("submit", function (e) {
      var form = this;
      if (klarnaSelected()) {
        e.preventDefault();
        authorize(function (result) {
          if (result.approved) {
            form.submit();
          } else {
            enableSaveOnClick();
          }
        }, function(result) {
          enableSaveOnClick();
        });
      }
    });

    initSession();
    return this;
  };

  // Reauthorization step before order confirmation.
  //
  // Call this on the confirmation page. It will hook into the form submit
  // and decide whether a reauth is necessary.
  $.fn.klarnaReauthorize = function(options) {
    var settings = $.extend({
      form: $("form.edit_order"),
      loader: $("<div class=\"klarna-loader\"></div>"),
      paymentUrl: Spree.url("/checkout/payment"),
      sessionLifetime: 3600, //seconds
      sessionUrl: Spree.url("/klarna/session"),
      submitButton: $("form.edit_order :submit")
    }, options);

    settings.form.on("submit", function(e) {
      var form = this;
      e.preventDefault();

      if (settings.submitButton) {
        settings.submitButton.attr("disabled", true).removeClass("primary").addClass("gray");
        settings.submitButton.after(settings.loader);
      }

      var confirmOrder = function() {
        form.submit();
      };

      verifyAuthorization(confirmOrder);
    });

    function updateSession(response, callback) {
      return $.ajax({
        method: "POST",
        url: settings.sessionUrl,
        dataType: "json",
        data: {token: response.authorization_token}
      }).done(function() {
        if (response.approved) {
          callback();
        } else {
          window.location.assign(settings.paymentUrl);
        }
      });
    }

    // Get a session from the backend and load the form
    function verifyAuthorization(callback) {
      // Get the current session from the backend
      $.ajax({
        method: "GET",
        url: settings.sessionUrl,
        dataType: "json"
      }).done(function(response) {
        // Is the session too old? status would be false.
        if (response.status) {
          // Check if the order is still the same
          if (!needsReauth(response.checksum)) {
            callback();
            return;
          }

          Klarna.Credit.init ({
            client_token: response.token
          });

          // Don"t send the merchant id"s, gets rejected from the endpoint
          delete response.data.merchant_urls;

          var updateSessionAndSubmit = function(response) {
            updateSession(response, callback);
          };

          Klarna.Credit.reauthorize(response.data, updateSessionAndSubmit);
        } else {
          window.location.assign(settings.paymentUrl);
        }
      });
    }

    // Check if the costly reauth can be omitted. This is possible when the serialized order did not change
    // and the order is only 1h old.
    function needsReauth(checksum) {
      if (!localStorageAvailable()) {
        return true;
      }
      if (localStorage.klarnaOrderChecksum !== checksum) {
        return true;
      }
      // order is older than sessionLifetime seconds
      if ((new Date() - Date.parse(localStorage.klarnaOrderTimestamp)) / 1000 >= settings.sessionLifetime) {
        return true;
      }
      return false;
    }
  };


  // see https://gist.github.com/paulirish/5558557
  function localStorageAvailable() {
    var t = "t";
    try {
      localStorage.setItem(t, t);
      localStorage.removeItem(t);
      return true;
    } catch(e) {
      return false;
    }
  }

  KlarnaGateway.loadSdk = function(w, d, callback) {
    var url = "https://credit.klarnacdn.net/lib/v1/api.js";
    var n = d.createElement("script");
    var c = d.getElementById("klarna-credit-lib-x");
    n.async = !0;
    n.src = url + "?" + (new Date ()).getTime();
    c.parentNode.replaceChild(n, c);
    n.onload = callback;
  };
}(window.KlarnaGateway = window.KlarnaGateway || {}, jQuery));
