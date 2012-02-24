class PatronTypesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @patron_type = PatronType.find(params[:id])
    if params[:move]
      move_position(@patron_type, params[:move])
      return
    end
    update!
  end

  def index
    @patron_types = @patron_types.page(params[:page])
  end
end
