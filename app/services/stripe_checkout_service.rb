# app/services/stripe_checkout_service.rb
class StripeCheckoutService
    def initialize(cart)
      @cart = cart
    end
  
    def create_session
      Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        line_items: build_line_items,
        mode: 'payment',
        success_url: Rails.application.routes.url_helpers.checkout_success_url + "?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: Rails.application.routes.url_helpers.cart_url,
        client_reference_id: @cart.id
      )
    end
  
    private
  
    def build_line_items
      @cart.cart_items.map do |item|
        {
          price_data: {
            currency: 'usd',
            unit_amount: (item.price * 100).to_i,
            product_data: {
              name: item.product.title,
              description: item.product.description
            }
          },
          quantity: item.quantity
        }
      end
    end
  end
  