class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    if current_user.role == 'seller'
      @products = current_user.products.page(params[:page]).per(3)
    else
      @products = Product.page(params[:page]).per(3)
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
      redirect_to @product, notice: 'Product created successfully.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
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
    params.require(:product).permit(:title, :description, :price,
      product_images_attributes: [:id, :image, :_destroy])
  end
end
