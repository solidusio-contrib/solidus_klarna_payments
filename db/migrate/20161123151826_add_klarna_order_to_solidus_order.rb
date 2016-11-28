class AddKlarnaOrderToSolidusOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :klarna_order_id, :string
    add_column :spree_orders, :klarna_order_state, :string
  end
end
