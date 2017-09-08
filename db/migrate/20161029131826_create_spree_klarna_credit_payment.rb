class CreateSpreeKlarnaCreditPayment < ActiveRecord::Migration
  def change
    create_table :spree_klarna_credit_payments do |t|
      t.references :spree_order
      t.string :klarna_order_id
      t.string :authorization_token
      t.string :fraud_status
      t.datetime :expires_at
      t.integer :payment_method_id
      t.integer :user_id
    end
    add_index :spree_klarna_credit_payments, :klarna_order_id
    add_index :spree_klarna_credit_payments, :authorization_token
  end
end
