class CarrierTypesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @carrier_type = CarrierType.find(params[:id])
    if params[:move]
      move_position(@carrier_type, params[:move])
      return
    end
    update!
  end
end
