class ReviewsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_product
  before_action :set_review, only: [:edit, :update, :destroy]

  def index
    @reviews = @product.reviews
    
  end

  def new
    @review = @product.reviews.build
  end

  def create
    @review = @product.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to product_path(@product), notice: 'Review was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @review.user == current_user && @review.update(review_params)
      redirect_to product_path(@product), notice: 'Review was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @review.user == current_user && @review.destroy
      redirect_to product_path(@product), notice: 'Review was successfully deleted.'
    else
      redirect_to product_path(@product), alert: 'Unable to delete review.'
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_review
    @review = Review.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:text)
  end
end
