class AddCustomerTokenToSpreeKlarnaCreditPayments < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_klarna_credit_payments, :customer_token, :string
  end
end
