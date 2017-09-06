module Admin
  class PromotionPage < SitePrism::Page
    set_url "/admin/promotions/{id}/edit"

    element :create_button, "[data-hook='buttons'] button"

    def create
      create_button.click
    end
  end
end
