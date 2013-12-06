class SeriesStatementMergesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_series_statement, :get_series_statement_merge_list

  # GET /series_statement_merges
  # GET /series_statement_merges.json
  def index
    if @series_statement
      @series_statement_merges = @series_statement.series_statement_merges.order('series_statement_merges.id').page(params[:page])
    elsif @series_statement_merge_list
      @series_statement_merges = @series_statement_merge_list.series_statement_merges.order('series_statement_merges.id').includes(:series_statement).page(params[:page])
    else
      @series_statement_merges = SeriesStatementMerge.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @series_statement_merges }
    end
  end

  # GET /series_statement_merges/1
  # GET /series_statement_merges/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @series_statement_merge }
    end
  end

  # GET /series_statement_merges/new
  # GET /series_statement_merges/new.json
  def new
    @series_statement_merge = SeriesStatementMerge.new
    @series_statement_merge.series_statement = @series_statement

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @series_statement_merge }
    end
  end

  # GET /series_statement_merges/1/edit
  def edit
  end

  # POST /series_statement_merges
  # POST /series_statement_merges.json
  def create
    @series_statement_merge = SeriesStatementMerge.new(params[:series_statement_merge])

    respond_to do |format|
      if @series_statement_merge.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.series_statement_merge'))
        format.html { redirect_to(@series_statement_merge) }
        format.json { render :json => @series_statement_merge, :status => :created, :location => @series_statement_merge }
      else
        format.html { render :action => "new" }
        format.json { render :json => @series_statement_merge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /series_statement_merges/1
  # PUT /series_statement_merges/1.json
  def update
    respond_to do |format|
      if @series_statement_merge.update_attributes(params[:series_statement_merge])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.series_statement_merge'))
        format.html { redirect_to(@series_statement_merge) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @series_statement_merge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /series_statement_merges/1
  # DELETE /series_statement_merges/1.json
  def destroy
    @series_statement_merge.destroy

    respond_to do |format|
      format.html { redirect_to(series_statement_merges_url) }
      format.json { head :no_content }
    end
  end

  private
  def get_series_statement_merge_list
    @series_statement_merge_list = SeriesStatementMerge_list.find(params[:series_statement_merge_list_id]) if params[:series_statement_merge_list_id]
  end
end
