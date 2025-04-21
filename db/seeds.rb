
coupons = { 'DevnTech' => 0.3, 'Pak14' => 0.5, 'lhr' => 0.2 }

coupons.each do |code, discount|
  Coupon.find_or_create_by(code: code) do |coupon|
    coupon.discount = discount
  end
end


Cart.update_all(discount_amount: 0.0) if Cart.where("discount_amount > 0").exists?