class SearchEnginesController < InheritedResources::Base
  respond_to :html, :xml
  load_and_authorize_resource

  def update
    @search_engine = SearchEngine.find(params[:id])
    if params[:position]
      @search_engine.insert_at(params[:position])
      redirect_to search_engines_url
      return
    end
    update!
  end

  def index
    @search_engines = @search_engines.page(params[:page])
  end
end
