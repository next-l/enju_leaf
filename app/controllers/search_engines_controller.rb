class SearchEnginesController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @search_engine = SearchEngine.find(params[:id])
    if params[:move]
      move_position(@search_engine, params[:move])
      return
    end
    update!
  end

  def index
    @search_engines = @search_engines.page(params[:page])
  end
end
