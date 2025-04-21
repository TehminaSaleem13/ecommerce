class DashboardController < ApplicationController
  include ProductFilterable
  before_action :authenticate_user!, except: [:index]
  include CartManagement

  def suggestions
    @products = Product.order(created_at: :desc).ransack(title_cont: params.dig(:q, :title_cont)).result(distinct: true)

    respond_to do |format|
      format.js
      format.html { render partial: 'products/search_suggestions', layout: false }
    end
  end
end