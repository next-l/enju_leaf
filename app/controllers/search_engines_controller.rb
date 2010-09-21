class SearchEnginesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
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

  protected
  def collection
    @search_engines ||= end_of_association_chain.paginate(:page => params[:page])
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.search_engine')}
  end
end
