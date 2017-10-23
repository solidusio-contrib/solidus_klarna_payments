module PageDrivers
  module Admin
    class NewPromotion < Base
      set_url '/admin/promotions/new'

      element :promotion_name_field, "input[name='promotion[name]']"
      element :promotion_desc_field, "textarea[name='promotion[description]']"
      element :create_button, "[data-hook='buttons'] button"

      if KlarnaGateway.is_spree?
        element :promotion_code_field, "input[name='promotion[code]']"
      else
        element :number_of_codes_field, "input[name='promotion_builder[number_of_codes]']"
        element :promotion_code_field, "input[name='promotion_builder[base_code]']"
      end


      def complete_form
        promotion_name_field.set('test')
        promotion_desc_field.set('test')
        promotion_code_field.set('test')

        if KlarnaGateway.is_solidus?
          number_of_codes_field.set('10')
        end
      end

      def continue
        create_button.click
      end
    end
  end
end
