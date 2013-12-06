class PatronRelationshipsController < InheritedResources::Base
  load_and_authorize_resource
  before_filter :prepare_options, :except => [:index, :destroy]

  def prepare_options
    @patron_relationship_types = PatronRelationshipType.all
  end

  def new
    @patron_relationship = PatronRelationship.new(params[:patron_relationship])
    @patron_relationship.parent = Patron.find(params[:patron_id]) rescue nil
    @patron_relationship.child = Patron.find(params[:child_id]) rescue nil
  end

  def update
    @patron_relationship = PatronRelationship.find(params[:id])
    if params[:position]
      @patron_relationship.insert_at(params[:position])
      redirect_to patron_relationships_url
      return
    end
    update!
  end
end
