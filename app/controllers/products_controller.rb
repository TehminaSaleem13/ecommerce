class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def search_suggestions
    @q = Product.ransack(params[:q])
    @products = @q.result(distinct: true).limit(5)
    
    respond_to do |format|
      format.html { render partial: 'products/search_suggestions', layout: false }
      format.js
    end
  end

  def index
    
    if user_signed_in?
      if current_user.role == 'seller'
        # For sellers, set up their products and the other products
        @your_products = current_user.products.page(params[:your_products_page]).per(3)
        @all_products = Product.where.not(user: current_user).page(params[:all_products_page]).per(3)
      else
        # For buyers
        @products = search_results.page(params[:page]).per(3)
      end
    else
      # For non-logged in users
      @products = search_results.page(params[:page]).per(3)
    end
  end

  def show
  end

  def new
    @product = current_user.products.build
    1.times { @product.product_images.build }
  end

  def create
    @product = current_user.products.build(product_params)
    
    if @product.save
      # Manually handle new image uploads
      if params[:product][:new_images]
        params[:product][:new_images].each do |new_image|
          @product.product_images.create(image: new_image)
        end
      end
      
      redirect_to @product, notice: 'Product created successfully.'
    else
      render :new
    end
  end
  
  
  def edit
    @product.product_images.build if @product.product_images.empty?
  end
  

  def update
    if @product.update(product_params)
      if params[:product][:new_images]
        params[:product][:new_images].each do |new_image|
          @product.product_images.create(image: new_image)
        end
      end
      redirect_to @product, notice: 'Product updated successfully.'
    else
      render :edit
    end
  end
  

  def destroy
    @product = Product.find(params[:id])
    if @product.destroy
      flash[:notice] = "Product deleted successfully"
      redirect_to root_path, turbolinks: false
    else
      flash[:alert] = "Failed to delete product"
      redirect_to root_path, turbolinks: false
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title, :description, :price,:quantity,
      product_images_attributes: [:id, :image, :_destroy])
  end
end
