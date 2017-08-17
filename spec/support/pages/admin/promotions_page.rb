module Admin
  class PromotionsPage < SitePrism::Page
    set_url "/admin/promotions/{number}/edit"

    element :add_rule_button, 'form#new_product_rule_form button'
    element :add_rule_button, 'form#new_promotion_action_form button'

    element :rule_amount_field, "input[name='promotion[promotion_rules_attributes][3][preferred_amount]']"
    element :select_currency_field, "select[name='promotion[promotion_rules_attributes][3][preferred_currency]']"
    element :action_amount_field, "input[name='promotion[promotion_actions_attributes][2][calculator_attributes][preferred_flat_percent]']"

    element :update_rule_button, "#rule_fields #edit_promotion_4 button[name='button']"
    element :update_rule_button, "#action_fields #edit_promotion_4 button[name='button']"

  end
end
