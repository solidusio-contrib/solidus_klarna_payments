Deface::Override.new(
  virtual_path: "spree/admin/shared/_order_submenu",
  insert_after: "[data-hook='admin_order_tabs_payments']",
  name: "add_klarna_tab_to_orders",
  partial: "spree/admin/shared/klarna_tab_order"
)
