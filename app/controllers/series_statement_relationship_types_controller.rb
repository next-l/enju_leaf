class SeriesStatementRelationshipTypesController < InheritedResources::Base
  add_breadcrumb "I18n.t('page.showing', :model => I18n.t('activerecord.models.series_statement_relationship_type'))", 'series_statement_relationship_type_path(params[:id])', :only => :show
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.series_statement_relationship_type'))", 'series_statement_relationship_types_path', :only => :index
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.series_statement_relationship_type'))", 'edit_series_statement_relationship_type_path(params[:id])', :only => [:edit, :update]
  load_and_authorize_resource

  def index
    @series_statement_relationship_types = SeriesStatementRelationshipType.page(params[:page] || 1)
  end

  def update
    if params[:move]
      move_position(@series_statement_relationship_type, params[:move])
    end
    update!
  end
end
