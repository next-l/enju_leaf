class FrequenciesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @frequency = Frequency.find(params[:id])
    if params[:position]
      @frequency.insert_at(params[:position])
      redirect_to frequencies_url
      return
    end
    update!
  end
end
