class CartsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :check_for_cart_merge, if: -> { user_signed_in? && session[:cart_needs_merge] }

  def check_for_cart_merge
 
    CartMerger.new(current_user, session).merge
    session.delete(:cart_needs_merge)

  end

  def show
   
    if user_signed_in?
    
      check_for_cart_merge if session[:cart_needs_merge]
      @cart = current_user.cart || current_user.create_cart
      
    else
      @cart = Cart.find_or_create_by(session_id: session.id.to_s)
    
    end
  
  end
end
