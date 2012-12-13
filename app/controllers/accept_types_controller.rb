class AcceptTypesController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    if params[:move]
      move_position(@accept_type, params[:move])
      return
    end
    update!
  end
end
