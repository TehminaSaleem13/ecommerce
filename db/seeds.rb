# db/seeds.rb
coupons = { 'DevnTech' => 0.3, 'Pak14' => 0.5, 'lhr' =>0.2 }

coupons.each do |code, discount|
  Coupon.create(code: code, discount: discount)
end
