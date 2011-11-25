class RealizeTypesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @realize_type = RealizeType.find(params[:id])
    if params[:position]
      @realize_type.insert_at(params[:position])
      redirect_to realize_types_url
      return
    end
    update!
  end
end
