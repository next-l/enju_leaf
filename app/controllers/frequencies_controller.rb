class FrequenciesController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @frequency = Frequency.find(params[:id])
    if params[:move]
      move_position(@frequency, params[:move])
      return
    end
    update!
  end
end
