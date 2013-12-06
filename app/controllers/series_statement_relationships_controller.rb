# TODO: NACSIS-CATからのインポートに未対応
class SeriesStatementRelationshipsController < InheritedResources::Base
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.series_statement_relationship'))", 'new_series_statement_relationship_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.showing', :model => I18n.t('activerecord.models.series_statement_relationship'))", 'series_statement_relationship_path(params[:id])',      :only => :show
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.series_statement_relationship'))", 'edit_series_statement_relationship_path(params[:id])', :only => [:edit, :update]
  respond_to :html, :json
  has_scope :page, :default => 1
  load_and_authorize_resource

  def index
    @relationship_family =  RelationshipFamily.find(params[:relationship_family_id])
  end

  def new
    prepare_options
    @relationship_family = RelationshipFamily.find(params[:relationship_family_id])
  end

  def create
    @series_statement_relationship = SeriesStatementRelationship.new(params[:series_statement_relationship])
    @relationship_family = RelationshipFamily.find(params[:series_statement_relationship][:relationship_family_id])
    SeriesStatementRelationship.transaction do  
      @series_statement_relationship.save!
      # シリーズとの関連を設定
      if params[:series_statement_relationship][:before_series_statement_relationship_id].present?
        before_series_statement = SeriesStatement.find(params[:series_statement_relationship][:before_series_statement_relationship_id])
        before_series_statement.update_attributes!(relationship_family_id: @relationship_family.id)
      end
      if params[:series_statement_relationship][:after_series_statement_relationship_id].present?
        after_series_statement = SeriesStatement.find(params[:series_statement_relationship][:after_series_statement_relationship_id])
        after_series_statement.update_attributes!(relationship_family_id: @relationship_family.id)
      end
      redirect_to @series_statement_relationship
    end
  rescue
    prepare_options
    render :action => :new
  end

  def edit
    prepare_options
    @relationship_family = @series_statement_relationship.relationship_family
  end

  def update
    @relationship_family = @series_statement_relationship.relationship_family
    before_relationship_series_statement_ids = @series_statement_relationship.relationship_family.series_statements.map(&:id)
    SeriesStatementRelationship.transaction do  
      @series_statement_relationship.update_attributes!(params[:series_statement_relationship])
      after_relationship_series_statement_ids = @series_statement_relationship.relationship_family.series_statement_relationships.inject([]){ |ids, obj| 
        ids << obj.before_series_statement_relationship_id unless obj.before_series_statement_relationship_id.nil? 
        ids << obj.after_series_statement_relationship_id unless obj.after_series_statement_relationship_id.nil?
      }
      # シリーズとの関連を設定
      if params[:series_statement_relationship][:before_series_statement_relationship_id].present?
        before_series_statement = SeriesStatement.find(params[:series_statement_relationship][:before_series_statement_relationship_id])
        unless before_series_statement.relationship_family == @relationship_family
          before_series_statement.update_attributes!(relationship_family_id: @relationship_family.id)
        end
      end
      if params[:series_statement_relationship][:after_series_statement_relationship_id].present?
        after_series_statement = SeriesStatement.find(params[:series_statement_relationship][:after_series_statement_relationship_id])
        unless after_series_statement.relationship_family == @relationship_family
          after_series_statement.update_attributes!(relationship_family_id: @relationship_family.id)
        end
      end
     # after_relationship_series_statement_ids = @series_statement_relationship.relationship_family.series_statements.map(&:id)
      # 関連がなくなったシリーズへの処理
      (before_relationship_series_statement_ids - after_relationship_series_statement_ids).each do |id|
        series_statement = SeriesStatement.find(id)
        series_statement.update_attributes!(relationship_family_id: nil)
      end 
    end
    redirect_to @series_statement_relationship
  rescue
    prepare_options
    render :action => :edit
  end

  def destroy
    relationship_family = @series_statement_relationship.relationship_family
    SeriesStatementRelationship.transaction do
      @series_statement_relationship.destroy
      if relationship_family.series_statement_relationships.size == 0
        relationship_family.series_statements.each do |series_statement|
          series_statement.update_attributes!(relationship_family_id: nil)
        end
      end 
      redirect_to relationship_family
    end
  rescue
    flash[:notice] = t('series_statement_relationship.failed_destroy')
    redirect_to relationship_family
  end

  private
  def prepare_options
    #TODO 始端、終端を自動登録できるようにしたい
    #@series_statement_relationship_types = SeriesStatementRelationshipType.selectable.select([:id, :display_name])
    @series_statement_relationship_types = SeriesStatementRelationshipType.select([:id, :display_name])
                                             .inject([]){ |types, type| types << [type.display_name, type.id] }
  end
end
