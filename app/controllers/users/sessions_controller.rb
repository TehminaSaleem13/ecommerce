

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]


  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end

  def create
    self.resource = warden.authenticate!(auth_options)

   
    set_flash_message(:notice, :signed_in, message: 'You have successfully logged in.') if is_flashing_format?
    redirect_to root_path, notice: "You have successfully logged in."

    # Sign the user in without redirecting
    sign_in(resource_name, resource)
    
    # Optionally yield to a block if necessary
    # yield resource if block_given?
    
    # Render the response with flash message without redirecting
    # render 'devise/sessions/new' # or any view you want to render
  end

  # DELETE /resource/sign_out
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out && is_flashing_format?
    yield if block_given?
    respond_to_on_destroy
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end
end
