class SeriesStatementRelationshipsController < InheritedResources::Base
  respond_to :html, :json
  has_scope :page, :default => 1
  load_and_authorize_resource

  def new
    @series_statement_relationship = SeriesStatementRelationship.new(params[:series_statement_relationship])
    @series_statement_relationship.parent = SeriesStatement.find(params[:parent_id]) rescue nil
    @series_statement_relationship.child = SeriesStatement.find(params[:child_id]) rescue nil
  end

  def update
    @series_statement_relationship = SeriesStatementRelationship.find(params[:id])
    if params[:move]
      move_position(@series_statement_relationship, params[:move])
      return
    end
    update!
  end
end
