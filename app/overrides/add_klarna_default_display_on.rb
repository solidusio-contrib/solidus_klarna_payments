Deface::Override.new(
  virtual_path: "spree/admin/payment_methods/_form",
  insert_after: "[data-hook='admin_payment_method_form_fields']",
  name: "add_klarna_default_display_on",
  partial: "spree/admin/payment_methods/default_display_on"
)
