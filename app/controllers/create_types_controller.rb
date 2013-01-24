class CreateTypesController < InheritedResources::Base
  respond_to :html, :json
  has_scope :page, :default => 1
  load_and_authorize_resource

  def update
    @create_type = CreateType.find(params[:id])
    if params[:move]
      move_position(@create_type, params[:move])
      return
    end
    update!
  end
end
