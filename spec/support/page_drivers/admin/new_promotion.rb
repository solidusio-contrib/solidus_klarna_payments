module PageDrivers
  module Admin
    class NewPromotion < SitePrism::Page
      set_url '/admin/promotions/new'

      element :promotion_name_field, "input[name='promotion[name]']"
      element :promotion_desc_field, "textarea[name='promotion[description]']"
      element :promotion_code_field, "input[name='promotion_builder[base_code]']"
      element :number_of_codes_field, "input[name='promotion_builder[number_of_codes]']"
      element :create_button, "[data-hook='buttons'] button"

      def complete_form
        promotion_name_field.set('test')
        promotion_desc_field.set('test')
        promotion_code_field.set('test')
        number_of_codes_field.set('10')
      end

      def continue
        create_button.click
      end
    end
  end
end
