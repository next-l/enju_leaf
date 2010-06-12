class CarrierTypesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
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

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.carrier_type')}
  end
end
