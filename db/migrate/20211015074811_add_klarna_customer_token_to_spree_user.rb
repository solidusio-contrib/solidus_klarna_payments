# frozen_string_literal: true

class AddKlarnaCustomerTokenToSpreeUser < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_users, :klarna_customer_token, :string
  end
end
