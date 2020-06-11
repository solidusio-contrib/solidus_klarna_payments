# frozen_string_literal: true

class ChangeKlarnaClientTokenToText < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up { change_column :spree_orders, :klarna_client_token, :text }
      dir.down { change_column :spree_orders, :klarna_client_token, :string }
    end
  end
end
