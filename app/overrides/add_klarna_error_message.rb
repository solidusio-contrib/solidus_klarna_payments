Deface::Override.new(
  virtual_path: "spree/admin/orders/edit",
  insert_top: "[data-hook='admin_order_edit_header']",
  name: "add_klarna_error_message",
  partial: "spree/admin/orders/error_message"
)
