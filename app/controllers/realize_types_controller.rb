class RealizeTypesController < InheritedResources::Base
  respond_to :html, :json
  has_scope :page, :default => 1
  load_and_authorize_resource

  def update
    @realize_type = RealizeType.find(params[:id])
    if params[:move]
      move_position(@realize_type, params[:move])
      return
    end
    update!
  end
end
