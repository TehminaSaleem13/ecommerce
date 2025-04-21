class AddFieldsToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :total_amount, :decimal
    add_column :orders, :subtotal, :decimal
    add_column :orders, :discount_amount, :decimal
    add_column :orders, :discount_percentage, :integer
    add_column :orders, :coupon_code, :string
  end
end
