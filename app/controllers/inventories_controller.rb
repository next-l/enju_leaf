class InventoriesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def index
    @inventories = @inventories.page(params[:page])
  end
end
