class ApplicationController < ActionController::Base
  include EnjuLibrary::Controller
  include EnjuBiblio::Controller
  include EnjuEvent::Controller
  include Pundit::Authorization
  after_action :verify_authorized, unless: :devise_controller?
  around_action :switch_locale
  impersonates :user

  private

  def get_subject_heading_type
    if params[:subject_heading_type_id]
      @subject_heading_type = SubjectHeadingType.find(params[:subject_heading_type_id])
      authorize @subject_heading_type, :show?
    end
  end

  def get_subject
    if params[:subject_id]
      @subject = Subject.find(params[:subject_id])
      authorize @subject, :show?
    end
  end

  def get_classification
    if params[:classification_id]
      @classification = Classification.find(params[:classification_id])
      authorize @classification, :show?
    end
  end

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
