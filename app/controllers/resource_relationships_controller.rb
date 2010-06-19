class ResourceRelationshipsController < InheritedResources::Base
  before_filter :prepare_options, :except => [:index, :destroy]

  def prepare_options
    @resource_relationship_types = ResourceRelationshipType.all
  end

  def new
    @resource_relationship = ResourceRelationship.new(params[:resource_relationship])
    @resource_relationship.parent = Resource.find(params[:resource_id]) rescue nil
    @resource_relationship.child = Resource.find(params[:child_id]) rescue nil
  end
end
