class CarrierTypesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @carrier_type = CarrierType.find(params[:id])
    if params[:position]
      @carrier_type.insert_at(params[:position])
      redirect_to carrier_types_url
      return
    end
    update!
  end
end
