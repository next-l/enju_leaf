class ResourceRelationshipsController < InheritedResources::Base
  before_filter :prepare_options, :except => [:index, :destroy]

  def prepare_options
    @resource_relationship_types = ResourceRelationshipType.all
  end
end
