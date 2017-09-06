class HomePage < SitePrism::Page
  set_url "/"

  elements :products,        "[data-hook='products_list_item']"
  elements :product_links,   "[data-hook='products_list_item'] a"
  element  :search_field,    "input#keywords"
  element  :search_dropdown, "select#taxon"
end
