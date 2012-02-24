class PatronRelationshipTypesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @patron_relationship_type = PatronRelationshipType.find(params[:id])
    if params[:move]
      move_position(@patron_relationship_type, params[:move])
      return
    end
    update!
  end
end
