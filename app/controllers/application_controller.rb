class ApplicationController < ActionController::Base
  include EnjuLibrary::Controller
  include EnjuBiblio::Controller
  include EnjuEvent::Controller
  include EnjuSubject::Controller
  include Pundit::Authorization
  after_action :verify_authorized, unless: :devise_controller?
  around_action :switch_locale
  impersonates :user

  private

  def switch_locale(&action)
    locale = params[:locale] || I18n.locale
    I18n.with_locale(locale, &action)
  end
end
