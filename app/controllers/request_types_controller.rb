class RequestTypesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @request_type = RequestType.find(params[:id])
    if params[:position]
      @request_type.insert_at(params[:position])
      redirect_to request_types_url
      return
    end
    update!
  end
end
