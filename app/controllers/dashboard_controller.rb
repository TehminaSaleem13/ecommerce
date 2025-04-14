class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if user_signed_in?
      if current_user.role == 'seller'
        @products = current_user.products.page(params[:page]).per(3)
      else
        @products = Product.page(params[:page]).per(3)
      end
    else
      redirect_to new_user_session_path, notice: 'Please sign in to access the dashboard.'
    end
  end
end
