class ApplicationController < ActionController::Base
  protect_from_forgery
  enju_leaf
  enju_biblio
  enju_library

  rescue_from CanCan::AccessDenied, :with => :render_403
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  rescue_from Errno::ECONNREFUSED, :with => :render_500
  rescue_from ActionView::MissingTemplate, :with => :render_404_invalid_format
  #rescue_from ActionController::RoutingError, :with => :render_404
end
