class MediumOfPerformancesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @medium_of_performance = MediumOfPerformance.find(params[:id])
    if params[:position]
      @medium_of_performance.insert_at(params[:position])
      redirect_to medium_of_performances_url
      return
    end
    update!
  end

  def index
    @medium_of_performances = @medium_of_performances.paginate(:page => params[:page])
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.medium_of_performance')}
  end
end
