class SeriesStatementMergeListsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  # GET /series_statement_merge_lists
  # GET /series_statement_merge_lists.json
  def index
    @series_statement_merge_lists = SeriesStatementMergeList.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @series_statement_merge_lists }
    end
  end

  # GET /series_statement_merge_lists/1
  # GET /series_statement_merge_lists/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @series_statement_merge_list }
    end
  end

  # GET /series_statement_merge_lists/new
  # GET /series_statement_merge_lists/new.json
  def new
    @series_statement_merge_list = SeriesStatementMergeList.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @series_statement_merge_list }
    end
  end

  # GET /series_statement_merge_lists/1/edit
  def edit
  end

  # POST /series_statement_merge_lists
  # POST /series_statement_merge_lists.json
  def create
    @series_statement_merge_list = SeriesStatementMergeList.new(params[:series_statement_merge_list])

    respond_to do |format|
      if @series_statement_merge_list.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.series_statement_merge_list'))
        format.html { redirect_to(@series_statement_merge_list) }
        format.json { render :json => @series_statement_merge_list, :status => :created, :location => @series_statement_merge_list }
      else
        format.html { render :action => "new" }
        format.json { render :json => @series_statement_merge_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /series_statement_merge_lists/1
  # PUT /series_statement_merge_lists/1.json
  def update
    respond_to do |format|
      if @series_statement_merge_list.update_attributes(params[:series_statement_merge_list])
        if params[:mode] == 'merge'
          selected_series_statement = SeriesStatement.find(params[:selected_series_statement_id]) rescue nil
          if selected_series_statement
            @series_statement_merge_list.merge_series_statements(selected_series_statement)
            flash[:notice] = t('merge_list.successfully_merged', :model => t('activerecord.models.series_statement'))
          else
            flash[:notice] = t('merge_list.specify_id', :model => t('activerecord.models.series_statement'))
            redirect_to series_statement_merge_list_url(@series_statement_merge_list)
            return
          end
        else
          flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.series_statement_merge_list'))
        end
        format.html { redirect_to(@series_statement_merge_list) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @series_statement_merge_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /series_statement_merge_lists/1
  # DELETE /series_statement_merge_lists/1.json
  def destroy
    @series_statement_merge_list.destroy

    respond_to do |format|
      format.html { redirect_to(series_statement_merge_lists_url) }
      format.json { head :no_content }
    end
  end
end
