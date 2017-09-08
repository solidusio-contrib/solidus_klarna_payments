Deface::Override.new(
  virtual_path: "spree/admin/orders/_risk_analysis",
  insert_bottom: "[data-hook='order_details_adjustments']",
  name: "add_klarna_risky_payments",
  partial: "spree/admin/orders/risky_klarna_payment"
)
