class ApplicationController < ActionController::Base
  protect_from_forgery
  include EnjuLeaf::Controller
  enju_biblio
  enju_library
  after_action :verify_authorized

  include Pundit
end
