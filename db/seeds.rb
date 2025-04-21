# db/seeds.rb
# Only create the coupons if they don't exist already
coupons = { 'DevnTech' => 0.3, 'Pak14' => 0.5, 'lhr' => 0.2 }

coupons.each do |code, discount|
  Coupon.find_or_create_by(code: code) do |coupon|
    coupon.discount = discount
  end
end

# Ensure all existing carts have the correct discount
Cart.update_all(discount_amount: 0.0) if Cart.where("discount_amount > 0").exists?