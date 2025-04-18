
module CartManagement
  extend ActiveSupport::Concern

  included do
    before_action :check_for_cart_merge, if: -> { user_signed_in? && session[:cart_needs_merge] }
  end

  protected

  def check_for_cart_merge
    # Remove the flag
    session.delete(:cart_needs_merge)
    
    
    redirect_to cart_path
  end
end