class DashboardController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def suggestions
    @products = Product.ransack(title_cont: params.dig(:q, :title_cont)).result(distinct: true).limit(5)
  
    respond_to do |format|
      format.js 
      format.html { render partial: 'products/search_suggestions', layout: false }
    end
  end
  
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
      redirect_to new_user_session_path, notice: 'Please sign in to access the dashboard.'
    end
  end
end