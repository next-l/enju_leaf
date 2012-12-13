class RetentionPeriodsController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @retention_periods = RetentionPeriod.find(params[:id])
    if params[:move]
      move_position(@retention_periods, params[:move])
      return
    end
    update!
  end
end
