class CreateTypesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @create_type = CreateType.find(params[:id])
    if params[:position]
      @create_type.insert_at(params[:position])
      redirect_to create_types_url
      return
    end
    update!
  end
end
