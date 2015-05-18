class SessionsController < ApplicationController
  def new
  end

  def create
    auth = request.env['omniauth.auth']
    identity = Identity.find_with_omniauth(auth)
    if auth['provider'] != 'identity'
      identity = Identity.create_with_omniauth(auth) unless identity
    end
    unless identity.user
      if current_user
        identity.user = current_user
      else
        user = User.create_with_omniauth(auth)
        identity.user = user
      end
      identity.save
    end
    session[:user_id] = identity.user.id
    redirect_to request.env['omniauth.origin'] || root_url, notice: "Signed in!"
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Signed out!"
  end

  def failure
    redirect_to new_session_url, notice: "Authentication failed, please try again."
  end
end
