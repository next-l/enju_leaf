class ProduceTypesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @produce_type = ProduceType.find(params[:id])
    if params[:position]
      @produce_type.insert_at(params[:position])
      redirect_to produce_types_url
      return
    end
    update!
  end
end
