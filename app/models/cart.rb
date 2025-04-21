# app/models/cart.rb
class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  belongs_to :user, optional: true

  attribute :coupon_code, :string

  attribute :discount_amount, :decimal

  after_initialize :set_default_discount

  def set_default_discount
 
    self.discount_amount = 0.0 if self.discount_amount.nil? || self.new_record?
   
  end

  def apply_coupon(code)
    coupon = Coupon.find_by(code: code)
    if coupon
      self.coupon_code = code
      self.discount_amount = coupon.discount
      save
      true
    else
      false
    end
  end

  def total_price
    subtotal * (1 - discount_amount)
  end

  def subtotal
    cart_items.sum { |item| item.product.price * item.quantity }
  end

  def discount_percentage
    (discount_amount * 100).to_i
  end

  def discount_value
    subtotal * discount_amount
  end

  def has_discount?
    discount_amount > 0
  end
end