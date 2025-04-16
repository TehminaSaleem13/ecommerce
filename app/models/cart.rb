class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  belongs_to :user, optional: true

  def apply_coupon(code)
    coupon = Coupon.find_by(code: code)
    if coupon
      cart_items.each do |item|
        item.update(price: item.product.price * (1 - coupon.discount))
      end
      true
    else
      false
    end
  end

  def total_price
    cart_items.sum(&:price)
  end
end
