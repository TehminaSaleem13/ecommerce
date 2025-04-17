class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :initialize_cart
  before_action :merge_guest_cart_to_user_cart, if: :user_signed_in?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :role, :avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar])
  end

  def initialize_cart
    session[:cart] ||= {}
    Rails.logger.info "Initialized cart: #{session[:cart]}"
  end

  def merge_guest_cart_to_user_cart
    return unless user_signed_in?
    
    # Skip if we've already merged the cart in this session
    return if session[:cart_merged]
    
    Rails.logger.info "Starting cart merge process for user #{current_user.id}"
    
    # Make sure user has a cart
    user_cart = current_user.cart || current_user.create_cart
    
    # First handle items in session[:cart]
    if session[:cart].present?
      Rails.logger.info "Merging session cart with user cart..."
      Rails.logger.info "Session cart before merge: #{session[:cart]}"
      
      # Store product IDs to remove (user's own products)
      products_to_remove = []
      
      session[:cart].each do |product_id, quantity|
        begin
          product = Product.find_by(id: product_id)
          
          # Skip if product not found
          unless product
            Rails.logger.info "Product #{product_id} not found, skipping"
            next
          end
          
          # If user owns this product, mark it for removal
          if current_user.id == product.user_id
            Rails.logger.info "Product #{product.title} belongs to current user, removing from cart"
            products_to_remove << product_id
            next
          end
          
          # Set exact quantity instead of incrementing
          cart_item = user_cart.cart_items.find_by(product: product)
          
          if cart_item
            # Update the existing cart item with the exact quantity from session
            cart_item.quantity = quantity.to_i
          else
            # Create a new cart item with the exact quantity
            cart_item = user_cart.cart_items.new(
              product: product,
              quantity: quantity.to_i,
              price: product.price
            )
          end
          
          if cart_item.save
            Rails.logger.info "Added/updated product #{product.title} in user cart with quantity #{quantity}"
          else
            Rails.logger.error "Failed to save cart item for product #{product.title}: #{cart_item.errors.full_messages.join(', ')}"
          end
        rescue => e
          Rails.logger.error "Error processing product #{product_id}: #{e.message}"
        end
      end
      
      # Remove the products that belong to the user
      products_to_remove.each { |id| session[:cart].delete(id) }
      
      # Clear session cart after merging
      session[:cart] = nil
      Rails.logger.info "Session cart merged successfully"
    end
    
    # Now handle database cart if it exists
    guest_cart = Cart.find_by(session_id: session.id.to_s)
    if guest_cart&.cart_items&.any?
      Rails.logger.info "Found guest database cart with #{guest_cart.cart_items.count} items"
      
      # Process each item in the guest cart
      guest_cart.cart_items.each do |item|
        begin
          # Skip if user owns this product
          if item.product && current_user.id == item.product.user_id
            Rails.logger.info "Product #{item.product.title} belongs to current user, skipping"
            item.destroy # Remove from guest cart
            next
          end
          
          # For valid items, transfer to user cart
          if item.product
            user_item = user_cart.cart_items.find_by(product: item.product)
            
            if user_item
              # Set exact quantity from guest cart
              user_item.quantity = item.quantity
            else
              # Create new item with exact quantity
              user_item = user_cart.cart_items.new(
                product: item.product,
                quantity: item.quantity,
                price: item.product.price
              )
            end
            
            if user_item.save
              Rails.logger.info "Transferred #{item.product.title} to user cart with quantity #{item.quantity}"
            else
              Rails.logger.error "Failed to transfer cart item: #{user_item.errors.full_messages.join(', ')}"
            end
          end
        rescue => e
          Rails.logger.error "Error transferring product: #{e.message}"
        end
      end
      
      # Apply coupon from guest cart if any
      if guest_cart.respond_to?(:coupon) && guest_cart.coupon.present?
        user_cart.apply_coupon(guest_cart.coupon.code) if user_cart.respond_to?(:apply_coupon)
        Rails.logger.info "Transferred coupon to user cart"
      elsif session[:coupon_code].present?
        user_cart.apply_coupon(session[:coupon_code]) if user_cart.respond_to?(:apply_coupon)
        session[:coupon_code] = nil
        Rails.logger.info "Applied session coupon code to user cart"
      end
      
      # Delete the guest cart
      guest_cart.destroy
      Rails.logger.info "Guest database cart deleted after merging with user cart"
    end
    
    # Mark that we've completed the merge
    session[:cart_merged] = true
    Rails.logger.info "Cart merge process completed"
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end
end