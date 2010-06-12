class RequestStatusTypesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @request_status_type = RequestStatusType.find(params[:id])
    if params[:position]
      @request_status_type.insert_at(params[:position])
      redirect_to request_status_types_url
      return
    end
    update!
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.request_status_type')}
  end
end
