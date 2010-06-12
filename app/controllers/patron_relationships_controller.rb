class PatronRelationshipsController < InheritedResources::Base
  before_filter :prepare_options, :except => [:index, :destroy]

  def prepare_options
    @patron_relationship_types = PatronRelationshipType.all
  end
end
