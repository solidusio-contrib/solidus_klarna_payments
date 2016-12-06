Deface::Override.new(
  virtual_path: "spree/admin/payments/_list",
  insert_after: "[data-hook='payments_row']",
  name: "add_klarna_info_to_payments",
  partial: "spree/admin/payments/klarna_info"
)
