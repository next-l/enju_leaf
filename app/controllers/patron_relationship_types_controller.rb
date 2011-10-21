class PatronRelationshipTypesController < InheritedResources::Base
  respond_to :html, :xml
  load_and_authorize_resource

  def update
    @patron_relationship_type = PatronRelationshipType.find(params[:id])
    if params[:position]
      @patron_relationship_type.insert_at(params[:position])
      redirect_to patron_relationship_types_url
      return
    end
    update!
  end
end
