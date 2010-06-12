class FormOfWorksController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @form_of_work = FormOfWork.find(params[:id])
    if params[:position]
      @form_of_work.insert_at(params[:position])
      redirect_to form_of_works_url
      return
    end
    update!
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.form_of_work')}
  end
end
