class KlarnaOrderWalkthrough

  def initialize(state: state, product_name: product_name, quantity: quantity, email: "spree@example.com", alternative_address: nil, differing_delivery_addrs: false)
    @product_name = product_name
    @quantity = quantity
    @state = state
    @email = email
    @alternative_address = alternative_address
    @differing_delivery_addrs = differing_delivery_addrs
  end

  def call
    @test_data = TestData.new($store_id)

    @order = Spree::Order.create!(
      email: (@alternative_address && @alternative_address.email) || @email,
      store: Spree::Store.first,
      guest_token: "xyz"
    )
    add_line_item!
    @order.next!

    states_to_process = if @state == :complete
                          states
                        else
                          end_state_position = states.index(@state.to_sym)
                          states[0..end_state_position]
                        end

    states_to_process.each do |state_to_process|
      send(state_to_process)
    end

    @order.update!
    @order
  end

  private

  def add_line_item!
    Spree::LineItem.create!(variant: Spree::Product.find_by_name(@product_name).master, quantity: @quantity, order: @order)
    @order.reload
  end

  def address
    address = @alternative_address || @test_data.address
    @order.ship_address = build_address(address)
    @order.bill_address = build_address(address, @differing_delivery_addrs)
    @order.save

    @order.next!
  end

  def delivery
    @order.next!
  end

  def states
    [:address, :delivery, :payment]
  end

  private

  def build_address(address, reversed=false)
    country = Spree::Country.find_by_iso(address.country_iso)
    state = country.states.find_by_name(address.state)
    address = Spree::Address.new(
         firstname: reversed ? address.first_name.reverse : address.first_name,
         lastname: reversed ? address.last_name.reverse : address.last_name,
         address1: reversed ? address.street_address.reverse : address.street_address,
         city: address.city,
         zipcode: reversed ? address.zip.reverse : address.zip,
         phone: address.phone,
         state: state,
         country: country)
  end
end
