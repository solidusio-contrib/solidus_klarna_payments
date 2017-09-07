class AddFailureData < ActiveRecord::Migration
  def change
    add_column :spree_klarna_credit_payments, :response_body, :text
    add_column :spree_klarna_credit_payments, :error_code, :string
    add_column :spree_klarna_credit_payments, :error_messages, :string
    add_column :spree_klarna_credit_payments, :correlation_id, :string
  end
end
