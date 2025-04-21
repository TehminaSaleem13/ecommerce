# db/migrate/xxxxxx_add_coupon_to_carts.rb
class AddCouponToCarts < ActiveRecord::Migration[6.0]
  def change
    add_reference :carts, :coupon, foreign_key: true, null: true
  end
end
