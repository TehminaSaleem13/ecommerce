
class CheckoutSuccessService
    def initialize(cart)
      @cart = cart
    end
  
    def process
      @cart.cart_items.each do |cart_item|
        product = cart_item.product
        if product.quantity >= cart_item.quantity
          product.update(quantity: product.quantity - cart_item.quantity)
        else
          Rails.logger.error("Insufficient quantity for product ID: #{product.id}")
        end
      end
      @cart.cart_items.destroy_all
    end
  end
  