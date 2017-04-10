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
        if (!response.token) {
          window.console && console.log("[Klarna Credit] received empty token:", response);
          displayError();
          return;
        }
        settings.clientToken = response.token;

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
