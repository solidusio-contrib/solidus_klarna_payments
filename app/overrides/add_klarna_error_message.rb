Deface::Override.new(
  virtual_path: "spree/admin/orders/customer_details/_form",
  insert_top: "[data-hook='admin_customer_detail_form_fields']",
  name: "add_klarna_error_message",
  partial: "spree/admin/orders/error_message"
)
