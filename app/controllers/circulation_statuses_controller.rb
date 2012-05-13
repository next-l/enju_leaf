class CirculationStatusesController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @circulation_status = CirculationStatus.find(params[:id])
    if params[:move]
      move_position(@circulation_status, params[:move])
      return
    end
    update!
  end
end
