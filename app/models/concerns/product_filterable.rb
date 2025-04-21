module ProductFilterable
  extend ActiveSupport::Concern

  included do
    before_action :set_products, only: [:index]
  end

  private

  def set_products
    if user_signed_in?
      if current_user.role == 'seller'
        @your_products = current_user.products.order(created_at: :desc).page(params[:your_products_page]).per(3)
        @all_products = Product.where.not(user: current_user).order(created_at: :desc).page(params[:all_products_page]).per(3)
      else
        @products = Product.order(created_at: :desc).page(params[:page]).per(3)
      end
    else
      @products = Product.order(created_at: :desc).page(params[:page]).per(3)
    end
  end
end
