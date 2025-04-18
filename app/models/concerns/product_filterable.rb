# app/controllers/concerns/product_filterable.rb
module ProductFilterable
    extend ActiveSupport::Concern
  
    included do
      before_action :set_products, only: [:index]
    end
  
    private
  
    def set_products
      @q = Product.ransack(params[:q])
      @search_results = @q.result(distinct: true)
  
      if user_signed_in?
        if current_user.role == 'seller'
          @your_products = current_user.products.page(params[:your_products_page]).per(3)
          @all_products = @search_results.where.not(user: current_user).page(params[:all_products_page]).per(3)
        else
          @products = @search_results.page(params[:page]).per(3)
        end
      else
        @products = @search_results.page(params[:page]).per(3)
      end
    end
  end
  