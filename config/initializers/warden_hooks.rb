Warden::Manager.after_set_user do |user, auth, opts|
  # Just set a flag in the session - don't try to use controllers here
  auth.session[:cart_needs_merge] = true
end