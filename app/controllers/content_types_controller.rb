class ContentTypesController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @content_type = ContentType.find(params[:id])
    if params[:move]
      move_position(@content_type, params[:move])
      return
    end
    update!
  end

  def index
    @content_types = @content_types.page(params[:page])
  end
end
