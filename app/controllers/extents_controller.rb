class ExtentsController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @extent = Extent.find(params[:id])
    if params[:position]
      @extent.insert_at(params[:position])
      redirect_to countries_url
      return
    end
    update!
  end

  protected
  def collection
    @extents ||= end_of_association_chain.paginate(:page => params[:page])
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.extent')}
  end
end
