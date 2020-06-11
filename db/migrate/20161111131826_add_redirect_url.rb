# frozen_string_literal: true

class AddRedirectUrl < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_klarna_credit_payments, :redirect_url, :string
  end
end
