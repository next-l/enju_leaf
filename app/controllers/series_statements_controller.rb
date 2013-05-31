# -*- encoding: utf-8 -*-
class SeriesStatementsController < ApplicationController
  add_breadcrumb "I18n.t('page.configuration')", 'page_configuration_path'
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.series_statement'))", 'series_statements_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.series_statement'))", 'new_series_statement_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.series_statement'))", 'edit_series_statement_path([:id])', :only => [:edit, :update]
  add_breadcrumb "I18n.t('activerecord.models.series_statement')", 'series_statement_path([:id])', :only => [:show]
  load_and_authorize_resource
  before_filter :get_work, :only => [:index, :new, :edit]
  before_filter :get_manifestation, :only => [:index, :new, :edit]
  before_filter :get_parent_and_child, :only => [:index, :new, :edit]
  before_filter :prepare_options, :only => [:new, :edit]
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
        if user_signed_in? and current_user.has_role?('Librarian')
          redirect_to series_statement_manifestations_url(@series_statement, :all_manifestations => true)
        else
          redirect_to series_statement_manifestations_url(@series_statement)
        end 
      }
      format.json { render :json => @series_statement }
      #format.js
      format.mobile {
        if user_signed_in? and current_user.has_role?('Librarian')
          redirect_to series_statement_manifestations_url(@series_statement, :all_manifestations => true)
        else
          redirect_to series_statement_manifestations_url(@series_statement)
        end
      }
    end

  end

  # GET /series_statements/new
  # GET /series_statements/new.json
  def new
    @series_statement = SeriesStatement.new
    @manifestation = @series_statement.root_manifestation
    @series_statement.root_manifestation = Manifestation.new
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
    @series_statement.root_manifestation = Manifestation.new unless @series_statement.root_manifestation
    if @series_statement.root_manifestation
      manifestation = @series_statement.root_manifestation 
      @creator = manifestation.creators.collect(&:full_name).flatten.join(';')
      @contributor = manifestation.contributors.collect(&:full_name).flatten.join(';')
      @publisher = manifestation.publishers.collect(&:full_name).flatten.join(';')
      @subject = manifestation.subjects.collect(&:term).join(';')
    end
  end

  # POST /series_statements
  # POST /series_statements.json
  def create
    @series_statement = SeriesStatement.new(params[:series_statement])
    @series_statement.root_manifestation = Manifestation.new
    manifestation = nil
    begin
      SeriesStatement.transaction do
        if params[:series_statement][:periodical].to_s == "1"
          manifestation = Manifestation.create(params[:manifestation])
          @series_statement.root_manifestation = manifestation
          manifestation.original_title = params[:series_statement][:original_title] if  params[:series_statement][:original_title]
          manifestation.title_transcription = params[:series_statement][:title_transcription] if params[:series_statement][:title_transcription]
          manifestation.title_alternative = params[:series_statement][:title_alternative] if params[:series_statement][:title_alternative]
          manifestation.periodical_master = true
          manifestation.save!
          @creator = params[:manifestation][:creator]
          @publisher = params[:manifestation][:publisher]
          @contributor = params[:manifestation][:contributor]
          @subject = params[:manifestation][:subject]
          manifestation.creators     = Patron.add_patrons(@creator) unless @creator.blank?
          manifestation.contributors = Patron.add_patrons(@contributor) unless @contributor.blank?
          manifestation.publishers   = Patron.add_patrons(@publisher) unless @publisher.blank?
          manifestation.subjects     = Subject.import_subject(@subject) unless @subject.blank?
        end
        @series_statement.save!
        @series_statement.manifestations << manifestation if @series_statement.periodical and manifestation
        respond_to do |format|
          format.html { redirect_to @series_statement,
            :notice => t('controller.successfully_created', :model => t('activerecord.models.series_statement')) }
          format.json { render :json => @series_statement, :status => :created, :location => @series_statement }
        end
      end
    rescue
      prepare_options
      @series_statement = SeriesStatement.create(params[:series_statement])
      @series_statement.root_manifestation = manifestation || Manifestation.new
      respond_to do |format|
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
          manifestation = nil
          @creator = params[:manifestation][:creator]
          @publisher = params[:manifestation][:publisher]
          @contributor = params[:manifestation][:contributor]
          @subject = params[:manifestation][:subject]
          if params[:series_statement][:periodical].to_s == "1"
            if @series_statement.root_manifestation
              manifestation = Manifestation.find(@series_statement.root_manifestation_id)
              manifestation.update_attributes!(params[:manifestation])
            else
              manifestation = Manifestation.new(params[:manifestation])
              @series_statement.root_manifestation = manifestation
              manifestation.original_title = params[:series_statement][:original_title] if params[:series_statement][:original_title]
              manifestation.title_transcription = params[:series_statement][:title_transcription] if params[:series_statement][:title_transcription]
              manifestation.title_alternative = params[:series_statement][:title_alternative] if params[:series_statement][:title_alternative]
              manifestation.periodical_master = true
              manifestation.save!
              @series_statement.manifestations << manifestation 
            end
            manifestation.creators     = Patron.add_patrons(@creator)
            manifestation.contributors = Patron.add_patrons(@contributor)
            manifestation.publishers   = Patron.add_patrons(@publisher) 
            manifestation.subjects     = Subject.import_subjects(@subject) 
            manifestation.save!
          else
            if @series_statement.root_manifestation
              manifestation = Manifestation.find(@series_statement.root_manifestation_id)
              manifestation.destroy if manifestation
            end
            @series_statement.root_manifestation = nil
            @series_statement.periodical = false
          end
          @series_statement.update_attributes!(params[:series_statement])
          @series_statement.manifestations.map { |manifestation| manifestation.index } if @series_statement.manifestations
          format.html { redirect_to @series_statement, :notice => t('controller.successfully_updated', :model => t('activerecord.models.series_statement')) }
          format.json { head :no_content }
        end
      rescue
        prepare_options
        @series_statement = SeriesStatement.create(params[:series_statement])
        @series_statement.root_manifestation = Manifestation.new unless @series_statement.root_manifestation_id
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
               manifestation = @series_statement.manifestations.first
               if manifestation == @series_statement.root_manifestation  
                 manifestation.destroy   
               end
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

  def prepare_options
    @carrier_types = CarrierType.all
    @manifestation_types = ManifestationType.where(:name => ['japanese_magazine', 'foreign_magazine', 'japanese_serial_book', 'foreign_serial_book'])
    @frequencies = Frequency.all
    @countries = Country.all
    @languages = Language.all_cache
    @roles = Role.all
  end
end
