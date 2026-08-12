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
    locale = params[:locale] || session[:locale] || I18n.locale
    session[:locale] = locale
    I18n.with_locale(locale, &action)
  end

  def default_url_options
    return super unless request.env["HTTP_ACCEPT_LANGUAGE"]

    requested_locale = params[:locale] || session[:locale]
    locale = I18n.available_locales.map(&:to_s).include?(requested_locale.to_s) ? requested_locale : nil

    if locale && locale != request.env["HTTP_ACCEPT_LANGUAGE"].scan(/^[a-z]{2}/)[0]
      { locale: locale }
    else
      super
    end
  end
end
