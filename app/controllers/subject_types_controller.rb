class SubjectTypesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @subject_type = SubjectType.find(params[:id])
    if params[:position]
      @subject_type.insert_at(params[:position])
      redirect_to subject_types_url
      return
    end
    update!
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.subject_type')}
  end
end
