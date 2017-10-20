if KlarnaGateway.up_to_spree?('2.3.99')
  Deface::Override.new(
    virtual_path: "spree/admin/payments/_list",
    insert_after: "[data-hook='payments_header'] th:nth-child(3)",
    name: "add_spree_klarna_info_header",
    text: "<th><%= Spree.t(:payment_info) %></th>"
  )

  Deface::Override.new(
    virtual_path: "spree/admin/payments/_list",
    insert_after: "[data-hook='payments_row'] td:nth-child(3)",
    name: "add_spree_klarna_info",
    partial: "spree/admin/payments/klarna_info"
  )
else
  Deface::Override.new(
    virtual_path: "spree/admin/payments/_list",
    replace: "[data-hook='payments_row'] td:nth-child(4)",
    name: "add_klarna_info_to_payments",
    partial: "spree/admin/payments/klarna_info"
  )
end
