class CheckoutSuccessService
  def initialize(cart)
    @cart = cart
    @user = cart.user
  end

  def process
 
    order = Order.create!(
      user: @user,
      status: 'paid',
      total_price: @cart.total_price,
      subtotal: @cart.subtotal,
      discount_amount: @cart.discount_value,
      discount_percentage: @cart.discount_percentage,
      coupon_code: @cart.coupon_code
    )
  
    @cart.cart_items.each do |cart_item|
      product = cart_item.product
      if product.quantity >= cart_item.quantity
      
        product.update(quantity: product.quantity - cart_item.quantity)
        cart_item.update(order_id: order.id)
      
      else
        Rails.logger.error("Insufficient quantity for product ID: #{product.id}")
      end
    end
    @cart.cart_items.destroy_all

    @cart.update(coupon_code: nil, discount_amount: 0.0)

    return order
  end
end
