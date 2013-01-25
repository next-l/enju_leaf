class CirculationStatusesController < InheritedResources::Base
  add_breadcrumb "I18n.t('activerecord.models.circulation_status')", 'circulation_statuses_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.circulation_status'))", 'new_circulation_status_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.circulation_status'))", 'edit_circulation_status_path(params[:id])', :only => [:edit, :update]
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
