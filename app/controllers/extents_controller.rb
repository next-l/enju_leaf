class ExtentsController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @extent = Extent.find(params[:id])
    if params[:move]
      move_position(@extent, params[:move])
      return
    end
    update!
  end

  def index
    @extents = @extents.page(params[:page])
  end
end
