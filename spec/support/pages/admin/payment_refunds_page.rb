module Admin
  class PaymentRefundsPage < SitePrism::Page
    set_url '/admin/orders/{number}/payments/{number}/refunds/new'

    element :reason_field, '#s2id_refund_refund_reason_id'
    element :continue_button, '#new_refund fieldset filter-actions button'
  end
end
