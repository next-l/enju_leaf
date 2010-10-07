class ContentTypesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @content_type = ContentType.find(params[:id])
    if params[:position]
      @content_type.insert_at(params[:position])
      redirect_to content_types_url
      return
    end
    update!
  end

  def index
    @content_types = @content_types.paginate(:page => params[:page])
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.content_type')}
  end
end
