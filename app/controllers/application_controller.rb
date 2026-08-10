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
    locale = params[:locale] || I18n.locale
    I18n.with_locale(locale, &action)
  end
end
