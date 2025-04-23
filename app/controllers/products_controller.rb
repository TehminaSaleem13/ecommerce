class ProductsController < ApplicationController
  include ProductFilterable
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  

  def show
  end

  def new
    @product = current_user.products.build
    1.times { @product.product_images.build }
  end

  def create
    @product = current_user.products.build(product_params)
      byebug
    if @product.save
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
    params.require(:product).permit(:title, :description, :price, :quantity,
      product_images_attributes: [:id, :image, :_destroy])
  end
end
