class AddKlarnaSessionToOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :klarna_session_id, :text
    add_column :spree_orders, :klarna_client_token, :string
    add_column :spree_orders, :klarna_session_expires_at, :datetime
  end
end
