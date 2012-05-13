class MediumOfPerformancesController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @medium_of_performance = MediumOfPerformance.find(params[:id])
    if params[:move]
      move_position(@medium_of_performance, params[:move])
      return
    end
    update!
  end

  def index
    @medium_of_performances = @medium_of_performances.page(params[:page])
  end
end
