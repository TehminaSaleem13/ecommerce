# app/controllers/checkout_controller.rb
class CheckoutController < ApplicationController
  before_action :authenticate_user!

  def create
    cart = current_user.cart
    if cart.blank? || cart.cart_items.empty?
      redirect_to cart_path, alert: 'Your cart is empty.' and return
    end

    if insufficient_inventory?(cart)
      redirect_to cart_path and return
    end

    session = StripeCheckoutService.new(cart).create_session
    redirect_to session.url, allow_other_host: true
  end

  def success
    session_id = params[:session_id]
    stripe_session = Stripe::Checkout::Session.retrieve(session_id)

    cart = current_user.cart
    CheckoutSuccessService.new(cart).process

    flash[:notice] = "Payment successful. Thank you for your purchase!"
    redirect_to root_path
  end

  private

  def insufficient_inventory?(cart)
    cart.cart_items.any? do |cart_item|
      if cart_item.product.quantity < cart_item.quantity
        flash[:alert] = "Insufficient quantity available for #{cart_item.product.title}. Only #{cart_item.product.quantity} available."
        true
      end
    end
  end
end
