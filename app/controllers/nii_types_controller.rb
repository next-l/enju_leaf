class NiiTypesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @nii_type = NiiType.find(params[:id])
    if params[:position]
      @nii_type.insert_at(params[:position])
      redirect_to nii_types_url
      return
    end
    update!
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.nii_type')}
  end
end
