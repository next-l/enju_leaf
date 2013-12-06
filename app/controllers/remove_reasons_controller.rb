class RemoveReasonsController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @remove_reasons = RemoveReason.find(params[:id])
    if params[:move]
      move_position(@remove_reasons, params[:move])
      return
    end
    update!
  end
end
