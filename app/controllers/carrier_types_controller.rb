class CarrierTypesController < InheritedResources::Base
  add_breadcrumb "I18n.t('activerecord.models.carrier_type')", 'carrier_types_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.carrier_type'))", 'new_carrier_type_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.carrier_type'))", 'edit_carrier_type_path(params[:id])', :only => [:edit, :update]
  respond_to :html, :json
  before_filter :check_client_ip_address
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
