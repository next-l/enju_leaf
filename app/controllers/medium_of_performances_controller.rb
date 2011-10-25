class MediumOfPerformancesController < InheritedResources::Base
  respond_to :html, :json
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
    @medium_of_performances = @medium_of_performances.page(params[:page])
  end
end
