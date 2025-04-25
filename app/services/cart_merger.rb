class CartMerger
  def initialize(user, session)
    @user = user
    @session = session
  end

  def merge
    return if @session[:cart_merged]

    user_cart = @user.cart || @user.create_cart
   

    merge_session_cart_to_user_cart(user_cart) if @session[:cart].present?
    merge_database_cart_to_user_cart(user_cart)

    @session[:cart_merged] = true
    
  end

  private

  def merge_session_cart_to_user_cart(user_cart)
   
    products_to_remove = []

    @session[:cart].each do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next unless product

      if @user.id == product.user_id
        products_to_remove << product_id
        next
      end

      update_or_create_cart_item(user_cart, product, quantity.to_i)
    end

    products_to_remove.each { |id| @session[:cart].delete(id) }
    @session[:cart] = nil
   
  end

  def merge_database_cart_to_user_cart(user_cart)
  
    guest_cart = Cart.find_by(session_id: @session.id.to_s)
    return unless guest_cart&.cart_items&.any?

    guest_cart.cart_items.each do |item|
      if item.product && @user.id == item.product.user_id
        item.destroy
        next
      end

      update_or_create_cart_item(user_cart, item.product, item.quantity) if item.product
    end

    transfer_coupon(user_cart, guest_cart)
    guest_cart.destroy
 
  end

  def update_or_create_cart_item(cart, product, quantity)
    return unless product

    cart_item = cart.cart_items.find_by(product: product)

    if cart_item
      cart_item.quantity += quantity
     
    else
      cart_item = cart.cart_items.new(
        product: product,
        quantity: quantity,
        price: product.price
      )
     
    end

    cart_item.save
  end

  def transfer_coupon(user_cart, guest_cart)
    if guest_cart.respond_to?(:coupon) && guest_cart.coupon.present?
      user_cart.apply_coupon(guest_cart.coupon.code) if user_cart.respond_to?(:apply_coupon)
      
    elsif @session[:coupon_code].present?
      user_cart.apply_coupon(@session[:coupon_code]) if user_cart.respond_to?(:apply_coupon)
      @session[:coupon_code] = nil
  
    end
  end
end
