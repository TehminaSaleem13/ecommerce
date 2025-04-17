class DashboardController < ApplicationController


  def index
    # Initialize ransack search object
    @q = Product.ransack(params[:q])

    if user_signed_in?
      if current_user.role == 'seller'
        @your_products = current_user.products.page(params[:your_products_page]).per(3)
        @all_products = Product.where.not(user: current_user).page(params[:all_products_page]).per(3)
      else
        @products = Product.page(params[:page]).per(3)
      end
    else
      # Changed to initialize @products for non-logged in users instead of redirecting
      # This is to match what your view expects for non-logged in users
      @products = Product.page(params[:page]).per(3)
    end
  end
end
