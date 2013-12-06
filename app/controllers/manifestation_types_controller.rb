class ManifestationTypesController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @manifestation_types = ManifestationType.find(params[:id])
    if params[:move]
      move_position(@manifestation_types, params[:move])
      return
    end
    update!
  end
end
