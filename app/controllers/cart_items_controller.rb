class CartItemsController < ApplicationController
  before_action :authenticate_user!, except: [:create, :apply_coupon]
  before_action :set_cart_item, only: [:update, :destroy]

  def create
    @product = Product.find(params[:product_id])
    if user_signed_in?
      @cart = current_user.cart || current_user.create_cart
    else
      @cart = Cart.find_or_create_by(session_id: session.id)
    end
    @cart_item = @cart.cart_items.find_or_initialize_by(product: @product)

    if @cart_item.persisted?
      @cart_item.quantity += 1
    else
      @cart_item.quantity = 1
      @cart_item.price = @product.price
    end

    if @cart_item.save
      redirect_to @product, notice: 'Product added to cart.'
    else
      redirect_to @product, alert: 'Failed to add product to cart.'
    end
  end

  def apply_coupon
    @cart = current_user.cart || Cart.find_or_create_by(session_id: session.id)
    if @cart.apply_coupon(params[:coupon_code])
      redirect_to cart_path, notice: 'Coupon applied successfully.'
    else
      redirect_to cart_path, alert: 'Invalid coupon code.'
    end
  end

  def update
    if @cart_item.update(cart_item_params)
      if @cart_item.quantity.zero?
        @cart_item.destroy
      end
      redirect_to cart_path(current_user.cart), notice: 'Cart item updated.'
    else
      redirect_to cart_path(current_user.cart), alert: 'Failed to update cart item.'
    end
  end

  def destroy
    if @cart_item.destroy
      redirect_to cart_path(current_user.cart), notice: 'Cart item removed.'
    else
      redirect_to cart_path(current_user.cart), alert: 'Failed to remove cart item.'
    end
  end

  private

  def set_cart_item
    @cart_item = CartItem.find(params[:id])
  end

  def cart_item_params
    params.require(:cart_item).permit(:quantity)
  end
end
