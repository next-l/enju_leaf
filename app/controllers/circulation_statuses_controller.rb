class CirculationStatusesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @circulation_status = CirculationStatus.find(params[:id])
    if params[:position]
      @circulation_status.insert_at(params[:position])
      redirect_to circulation_statuses_url
      return
    end
    update!
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.circulation_status')}
  end
end
