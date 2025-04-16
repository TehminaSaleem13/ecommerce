class CheckoutController < ApplicationController
    before_action :authenticate_user!
  
    def create
      cart = current_user.cart
      if cart.blank? || cart.cart_items.empty?
        redirect_to cart_path, alert: 'Your cart is empty.'
        return
      end
  
      session = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        line_items: cart.cart_items.map do |item|
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
        end,
        mode: 'payment',
        success_url: checkout_success_url + "?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: cart_url
      )
  
      redirect_to session.url, allow_other_host: true
    end
  
    def success
      session_id = params[:session_id]
      session = Stripe::Checkout::Session.retrieve(session_id)
  
      # Mark cart as purchased
      current_user.cart.cart_items.destroy_all
  
      flash[:notice] = "Payment successful. Thank you for your purchase!"
      redirect_to root_path
    end
  end
  