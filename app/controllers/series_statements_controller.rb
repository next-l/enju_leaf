# -*- encoding: utf-8 -*-
class SeriesStatementsController < ApplicationController
  load_and_authorize_resource
  before_filter :get_work, :only => [:index, :new, :edit]
  before_filter :get_manifestation, :only => [:index, :new, :edit]
  before_filter :get_parent_and_child, :only => [:index, :new, :edit]
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]
  after_filter :solr_commit, :only => [:create, :update, :destroy]

  # GET /series_statements
  # GET /series_statements.json
  def index
    search = Sunspot.new_search(SeriesStatement)
    query = params[:query].to_s.strip
    page = params[:page] || 1
    unless query.blank?
      @query = query.dup
      query = query.gsub('　', ' ')
    end
    search.build do
      fulltext query if query.present?
      paginate :page => page.to_i, :per_page => SeriesStatement.default_per_page
      order_by :position, :asc
    end
    #work = @work
    manifestation = @manifestation
    parent = @parent
    child = @child
    unless params[:mode] == 'add'
      search.build do
      #  with(:work_id).equal_to work.id if work
        with(:parent_ids).equal_to parent.id if parent
        with(:child_ids).equal_to child.id if child
        with(:manifestation_ids).equal_to manifestation.id if manifestation
      end
    else
      search.build do
        without(:parent_ids, parent.id) if parent
      end
    end
    page = params[:page] || 1
    search.query.paginate(page.to_i, SeriesStatement.default_per_page)
    @series_statements = search.execute!.results

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @series_statements }
    end
  end

  # GET /series_statements/1
  # GET /series_statements/1.json
  def show
    #@manifestations = @series_statement.manifestations.periodical_children.page(params[:manifestation_page]).per_page(Manifestation.default_per_page)

    respond_to do |format|
      format.html { # show.html.erb
        redirect_to series_statement_manifestations_url(@series_statement)
      }
      format.json { render :json => @series_statement }
      #format.js
      format.mobile {
        redirect_to series_statement_manifestations_url(@series_statement)
      }
    end

  end

  # GET /series_statements/new
  # GET /series_statements/new.json
  def new
    @series_statement = SeriesStatement.new
    @series_statement.parent = @parent_series_statement if @parent_series_statement

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @series_statement }
    end
  end

  # GET /series_statements/1/edit
  def edit
    @series_statement.work = @work if @work
    @series_statement.parent = @parent_series_statement if @parent_series_statement
  end

  # POST /series_statements
  # POST /series_statements.json
  def create
    @series_statement = SeriesStatement.new(params[:series_statement])
    manifestation = Manifestation.find(@series_statement.manifestation_id) rescue nil

    respond_to do |format|
      if @series_statement.save
        @series_statement.manifestations << manifestation if manifestation
        format.html { redirect_to @series_statement, :notice => t('controller.successfully_created', :model => t('activerecord.models.series_statement')) }
        format.json { render :json => @series_statement, :status => :created, :location => @series_statement }
      else
        format.html { render :action => "new" }
        format.json { render :json => @series_statement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /series_statements/1
  # PUT /series_statements/1.json
  def update
    if params[:move]
      move_position(@series_statement, params[:move])
      return
    end

    respond_to do |format|
      begin
        SeriesStatement.transaction do
          unless params[:series_statement][:periodical] == 0.to_s
            unless @series_statement.root_manifestation
              manifestation = Manifestation.new(
                :original_title => @series_statement.original_title,
              )
              manifestation.periodical_master = true
              @series_statement.root_manifestation = manifestation
              @series_statement.manifestations << manifestation
            end
          else
            @series_statement.manifestations.collect{ |manifestation| manifestation.destroy if manifestation.periodical_master }
            @series_statement.root_manifestation_id = nil
          end

          @series_statement.update_attributes(params[:series_statement])
          @series_statement.manifestations.map { |manifestation| manifestation.index }
          format.html { redirect_to @series_statement, :notice => t('controller.successfully_updated', :model => t('activerecord.models.series_statement')) }
          format.json { head :no_content }
        end
      rescue 
        format.html { render :action => "edit" }
        format.json { render :json => @series_statement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /series_statements/1
  # DELETE /series_statements/1.json
  def destroy
    respond_to do |format|
      begin
        SeriesStatement.transaction do
          if @series_statement.manifestations
            if @series_statement.manifestations.size == 1
               @series_statement.manifestations.first.destroy   
            end
          end
          @series_statement.destroy
          format.html { redirect_to series_statements_url }
          format.json { head :no_content }
        end
      rescue
        format.html { redirect_to(series_statements_path) }
        format.json { render :json => @series_statement.errors, :status => :unprocessable_entity }
      end
    end
  end

  private
  def get_parent_and_child
    @parent = SeriesStatement.find(params[:parent_id]) if params[:parent_id]
    @child = SeriesStatement.find(params[:child_id]) if params[:child_id]
  end
end
