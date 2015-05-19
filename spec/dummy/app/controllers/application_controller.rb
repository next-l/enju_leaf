class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery
  enju_leaf
  enju_biblio
  enju_library

  helper_method :current_user

  private
  def current_user  
    @current_user ||= User.find(session[:user_id]) if session[:user_id]  
  end 
end
