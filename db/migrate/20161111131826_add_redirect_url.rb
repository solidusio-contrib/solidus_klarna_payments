class AddRedirectUrl < ActiveRecord::Migration
  def change
    add_column :spree_klarna_credit_payments, :redirect_url, :string
  end
end
