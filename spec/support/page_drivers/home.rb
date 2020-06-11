# frozen_string_literal: true

module PageDrivers
  class Home < Base
    set_url "/"
    elements :products, '#content #products [data-hook="products_list_item"]'

    def choose(name)
      products.find{ |e| e.text.match(name) }.click
    end
  end
end
