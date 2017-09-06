Deface::Override.new(
  virtual_path: "spree/admin/payment_methods/_form",
  insert_top: "[data-hook='admin_payment_method_form_fields']",
  name: "add_klarna_credentials_log",
  partial: "spree/admin/payment_methods/klarna_credentials_log"
)
