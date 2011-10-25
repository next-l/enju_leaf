class ManifestationRelationshipTypesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @manifestation_relationship_type = ManifestationRelationshipType.find(params[:id])
    if params[:position]
      @manifestation_relationship_type.insert_at(params[:position])
      redirect_to manifestation_relationship_types_url
      return
    end
    update!
  end
end
