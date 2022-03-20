class ApplicationController < ActionController::Base
  include EnjuLibrary::Controller
  include EnjuBiblio::Controller
  include EnjuEvent::Controller
  include EnjuSubject::Controller
  include Pundit::Authorization
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :verify_authorized, unless: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
  end
end
