class ApplicationController < ActionController::Base
  protect_from_forgery
  include EnjuBiblio::Controller
  include EnjuLibrary::Controller
  after_action :verify_authorized

  include Pundit
end
