class CheckoutController < ApplicationController
  def create
    if user_signed_in?
      cart = current_user.cart
      if cart.blank? || cart.cart_items.empty?
        redirect_to cart_path, alert: 'Your cart is empty.' and return
      end

      if insufficient_inventory?(cart)
        redirect_to cart_path and return
      end

      begin
        
        session = StripeCheckoutService.new(cart).create_session
       
        redirect_to session.url, allow_other_host: true
      rescue Stripe::CardError => e
        flash[:alert] = "Payment error: #{e.message}"
        redirect_to cart_path
      rescue StandardError => e
        Rails.logger.error("Stripe session creation error: #{e.message}")
        flash[:alert] = "An error occurred while processing your payment. Please try again."
        redirect_to cart_path
      end
    else
      redirect_to new_user_session_path, alert: 'Please sign in or sign up to proceed with checkout.'
    end
  end

  def success
    session_id = params[:session_id]
    
    if session_id.blank?
      flash[:alert] = "Invalid checkout session"
      redirect_to cart_path and return
    end
    
    begin
      stripe_session = Stripe::Checkout::Session.retrieve(session_id)
      
 byebug
      cart = current_user.cart
      if stripe_session.client_reference_id.to_i != cart.id
        flash[:alert] = "Invalid checkout session"
        redirect_to cart_path and return
      end
      
   
      order = CheckoutSuccessService.new(cart).process
  byebug
      flash[:notice] = "Order ##{order.id} has been placed successfully! Thank you for your purchase!"
      redirect_to root_path
    rescue StandardError => e
      Rails.logger.error("Checkout processing failed: #{e.message}")
      flash[:alert] = "There was a problem processing your order. Please contact support."
      redirect_to cart_path
    end
  end

  private

  def insufficient_inventory?(cart)
    cart.cart_items.any? do |cart_item|
      product_quantity = cart_item.product.quantity
      if product_quantity.nil? || product_quantity < cart_item.quantity
        flash[:alert] = "Insufficient quantity available for #{cart_item.product.title}. Only #{product_quantity} available."
        true
      end
    end
  end
end