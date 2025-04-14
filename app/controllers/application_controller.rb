class ApplicationController < ActionController::Base
    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :initialize_cart
  
    protected
  
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :role, :avatar])
      devise_parameter_sanitizer.permit(:account_update, keys: [:avatar])
    end
  
    def initialize_cart
      @cart = session[:cart] ||= {}
    end
  
    def merge_guest_cart_to_user_cart
      return unless session[:cart].present?
  
      session[:cart].each do |product_id, quantity|
        product = Product.find(product_id)
        cart_item = current_user.cart.cart_items.find_or_initialize_by(product: product)
        cart_item.quantity += quantity
        cart_item.price = product.price
        cart_item.save
      end
  
      session[:cart] = nil
    end
  end
  