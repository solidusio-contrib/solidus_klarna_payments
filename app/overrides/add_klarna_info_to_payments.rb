Deface::Override.new(
  virtual_path: "spree/admin/payments/_list",
  replace: "[data-hook='payments_row'] td:nth-child(4)",
  name: "add_klarna_info_to_payments",
  partial: "spree/admin/payments/klarna_info"
)
