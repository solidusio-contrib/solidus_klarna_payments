class KlarnaOrderWalkthrough

  def initialize(state: state, product_name: product_name, quantity: quantity)
    @product_name = product_name
    @quantity = quantity
    @state = state
  end

  def call
    @test_data = TestData.new($store_id)

    @order = Spree::Order.create!(
      email: "spree@example.com",
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

    @order
  end

  private

  def add_line_item!
    Spree::LineItem.create!(variant: Spree::Product.find_by_name(@product_name).master, quantity: @quantity, order: @order)
    @order.reload
  end

  def address
    country = Spree::Country.find_by_iso(@test_data.address.country_iso)
    state = country.states.find_by_name(@test_data.address.state)
    address = Spree::Address.new(
         firstname: @test_data.address.first_name,
         lastname: @test_data.address.last_name,
         address1: @test_data.address.street_address,
         city: @test_data.address.city,
         zipcode: @test_data.address.zip,
         phone: @test_data.address.phone,
         state: state,
         country: country)

    @order.ship_address = address.dup
    @order.bill_address = address.dup
    @order.save

    @order.next!
  end

  def delivery
    @order.next!
  end

  def states
    [:address, :delivery, :payment]
  end
end
