class PatronRelationshipTypesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
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

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.patron_relationship_type')}
  end
end
