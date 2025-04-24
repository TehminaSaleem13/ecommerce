class Users::RegistrationsController < Devise::RegistrationsController
 
  def create
  
    @user = User.new(sign_up_params)

    if @user.save
      attach_default_avatar unless params[:user][:avatar].present?
     
      redirect_to new_user_session_path
    else
      render :new
    end
  end

  def new
    @resource = User.new
    super
  end

 
  def update
    self.resource = current_user
    
    if resource.update(account_update_params)
      if request.xhr?
    
        render json: { success: true }
      else
        
        flash[:notice] = "Avatar updated successfully"
        redirect_back(fallback_location: root_path)
      end
    else
      if request.xhr?
        render json: { success: false, errors: resource.errors.full_messages }, status: :unprocessable_entity
      else
        respond_with resource
      end
    end
  end
  
  
  private
  
 
  def attach_default_avatar
    avatar_path = Rails.root.join('app', 'assets', 'images', 'avatar.png')
    
   
    if File.exist?(avatar_path)
      @user.avatar.attach(
        io: File.open(avatar_path),
        filename: 'avatar.png',
        content_type: 'image/png'
      )
    else
      Rails.logger.error("Default avatar image not found at #{avatar_path}")
    end
  end

  
  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :role, :avatar)
  end


  def account_update_params
    params.require(:user).permit(:avatar)
  end
end