class DashboardController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    if user_signed_in?
      if current_user.role == 'seller'
        @your_products = current_user.products.page(params[:your_products_page]).per(3)
        @all_products = Product.where.not(user: current_user).page(params[:all_products_page]).per(3)
      else
        @products = Product.page(params[:page]).per(3)
      end
    else
      redirect_to new_user_session_path, notice: 'Please sign in to access the dashboard.'
    end
  end
end
