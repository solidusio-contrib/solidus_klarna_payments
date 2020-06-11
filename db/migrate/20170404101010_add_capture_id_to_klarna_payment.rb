# frozen_string_literal: true

class AddCaptureIdToKlarnaPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_klarna_credit_payments, :capture_id, :string
  end
end
