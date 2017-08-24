module PageDrivers
  module Admin
    class Promotion < SitePrism::Page
      set_url '/admin/promotions/{id}/edit'

      element :add_rule_button, 'form#new_product_rule_form button'
      element :add_action_button, 'form#new_promotion_action_form button'

      element :rule_amount_field, "input[id*='preferred_amount']"
      element :select_currency_field, "select#promotion_promotion_actions_attributes_7_calculator_attributes_preferred_flat_percent"
      element :action_amount_field, "input[id*='_calculator_attributes_preferred_flat_percent']"

      element :update_rule_button, "div[id='rules_container'] form[class='edit_promotion'] fieldset button"
      element :update_action_button, "div[id='actions_container'] form[class='edit_promotion'] button"

      def add_rule
        add_rule_button.click
      end

      def add_action
        add_action_button.click
      end

      def complete_rule_form
        rule_amount_field.set('10.0')
      end

      def complete_promotion_form
        action_amount_field.set('10')
      end

      def update_rule
        update_rule_button.click
      end

      def update_action
        update_action_button.click
      end

      def complete_form
        promotion_name_field.set('test')
        promotion_desc_field.set('test')
        promotion_code_field.set('test')
      end

      def continue
        create_button.click
      end
    end
  end
end
