class ApplicationController < ActionController::Base
  include EnjuLibrary::Controller
  include EnjuBiblio::Controller
  include EnjuEvent::Controller
  include EnjuSubject::Controller
  include Pundit
  after_action :verify_authorized, unless: :devise_controller?
end
