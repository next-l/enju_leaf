class ManifestationRelationshipsController < InheritedResources::Base
  load_and_authorize_resource
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
    if params[:move]
      move_position(@manifestation_relationship, params[:move])
      return
    end
    update!
  end
end
