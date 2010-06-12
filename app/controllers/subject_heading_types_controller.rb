class SubjectHeadingTypesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @subject_heading_type = SubjectHeadingType.find(params[:id])
    if params[:position]
      @subject_heading_type.insert_at(params[:position])
      redirect_to subject_heading_types_url
      return
    end
    update!
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.subject_heading_type')}
  end
end
