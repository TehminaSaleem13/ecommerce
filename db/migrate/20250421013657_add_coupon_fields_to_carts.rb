class AddCouponFieldsToCarts < ActiveRecord::Migration[6.1]
  def change
    add_column :carts, :coupon_code, :string
    add_column :carts, :discount_amount, :decimal, precision: 5, scale: 2, default: 0.0
  end
end
