class CartsController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def show
    Rails.logger.info "Session: #{session.inspect}"
    if user_signed_in?
      @cart = current_user.cart || current_user.create_cart
    else
      @cart = Cart.find_or_create_by(session_id: session.id.to_s)
      Rails.logger.info "Guest cart retrieved with session_id: #{session.id.to_s}"
    end
    Rails.logger.info "Cart: #{@cart.inspect}"
    Rails.logger.info "Cart items: #{@cart.cart_items.inspect}"
  end
end
