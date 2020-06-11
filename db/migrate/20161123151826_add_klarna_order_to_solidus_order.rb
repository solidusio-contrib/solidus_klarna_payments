# frozen_string_literal: true

class AddKlarnaOrderToSolidusOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_orders, :klarna_order_id, :string
    add_column :spree_orders, :klarna_order_state, :string
  end
end
