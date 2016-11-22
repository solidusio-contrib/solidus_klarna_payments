Deface::Override.new(
  virtual_path: "spree/checkout/_confirm",
  insert_before: "[data-hook='buttons']",
  name: "add_klarna_reauthorize_to_confirmation",
  partial: "spree/checkout/payment/klarna_reauthorize"
)
