class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :initialize_cart

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :role, :avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar])
  end

  def initialize_cart
    session[:cart] ||= {}
   
  end

  def after_sign_in_path_for(resource)
    root_path
  end
end