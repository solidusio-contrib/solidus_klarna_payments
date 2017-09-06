class AddKlarnaInfoToKlarnaPayment < ActiveRecord::Migration
  def change
    add_column :spree_klarna_credit_payments, :status, :string
    add_column :spree_klarna_credit_payments, :purchase_currency, :string
    add_column :spree_klarna_credit_payments, :locale, :string

    rename_column :spree_klarna_credit_payments, :klarna_order_id, :order_id
  end
end
