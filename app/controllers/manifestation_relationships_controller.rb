class ManifestationRelationshipsController < InheritedResources::Base
  load_and_authorize_resource
  helper_method :get_manifestation
  before_filter :prepare_options, :except => [:index, :destroy]

  def prepare_options
    @manifestation_relationship_types = ManifestationRelationshipType.all
  end

  def new
    @manifestation_relationship = ManifestationRelationship.new(params[:manifestation_relationship])
    @manifestation_relationship.parent = Manifestation.find(params[:manifestation_id]) rescue nil
    @manifestation_relationship.child = Manifestation.find(params[:child_id]) rescue nil
  end

  def update
    @manifestation_relationship = ManifestationRelationship.find(params[:id])
    if params[:position]
      @manifestation_relationship.insert_at(params[:position])
      redirect_to manifestation_relationships_url
      return
    end
    update!
  end
end
