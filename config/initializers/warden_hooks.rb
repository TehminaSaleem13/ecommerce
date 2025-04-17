# config/initializers/warden_hooks.rb
Warden::Manager.after_set_user do |user, auth, opts|
    if user && auth.env['warden.options'][:action] == 'unauthenticated'
      Rails.logger.info "User logged in: #{user.inspect}"
      ApplicationController.new.send(:merge_guest_cart_to_user_cart)
    end
  end
  