class FrequenciesController < InheritedResources::Base
  respond_to :html, :json
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
