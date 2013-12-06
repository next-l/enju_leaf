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

    @basket = Basket.find(params[:basket_id]) if params[:basket_id]

    #work = @work
    manifestation = @manifestation
    unless params[:mode] == 'add'
      search.build do
      #  with(:work_id).equal_to work.id if work
        with(:manifestation_ids).equal_to manifestation.id if manifestation
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

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @series_statement }
    end
  end

  # GET /series_statements/1/edit
  def edit
    @series_statement.work = @work if @work
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
    @series_statement.root_manifestation = Manifestation.new(params[:manifestation])
    SeriesStatement.transaction do
      if @series_statement.periodical
        @series_statement.root_manifestation.original_title = params[:series_statement][:original_title] if  params[:series_statement][:original_title]
        @series_statement.root_manifestation.title_transcription = params[:series_statement][:title_transcription] if params[:series_statement][:title_transcription]
        @series_statement.root_manifestation.title_alternative = params[:series_statement][:title_alternative] if params[:series_statement][:title_alternative]
        @series_statement.root_manifestation.periodical_master = true
        @creator = params[:manifestation][:creator]
        @publisher = params[:manifestation][:publisher]
        @contributor = params[:manifestation][:contributor]
        @subject = params[:manifestation][:subject]
        @series_statement.root_manifestation.creators     = Patron.add_patrons(@creator) unless @creator.blank?
        @series_statement.root_manifestation.contributors = Patron.add_patrons(@contributor) unless @contributor.blank?
        @series_statement.root_manifestation.publishers   = Patron.add_patrons(@publisher) unless @publisher.blank?
        @series_statement.root_manifestation.subjects     = Subject.import_subject(@subject) unless @subject.blank?
        @series_statement.root_manifestation.save! # if @series_statement.periodical
        @series_statement.manifestations << @series_statement.root_manifestation
    end
      @series_statement.save!
      respond_to do |format|
        format.html { redirect_to @series_statement,
          :notice => t('controller.successfully_created', :model => t('activerecord.models.series_statement')) }
        format.json { render :json => @series_statement, :status => :created, :location => @series_statement }
      end
    end
    rescue Exception => e
      logger.error "Failed to create: #{e}"
      prepare_options
      respond_to do |format|
        format.html { render :action => "new" }
        format.json { render :json => @series_statement.errors, :status => :unprocessable_entity }
      end
  end

  # PUT /series_statements/1
  # PUT /series_statements/1.json
  def update
    if params[:move]
      move_position(@series_statement, params[:move])
      return
    end
    @series_statement.assign_attributes(params[:series_statement])
    @series_statement.root_manifestation = @series_statement.root_manifestation if @series_statement.root_manifestation

    respond_to do |format|
      begin
        SeriesStatement.transaction do
          @creator = params[:manifestation][:creator]
          @publisher = params[:manifestation][:publisher]
          @contributor = params[:manifestation][:contributor]
          @subject = params[:manifestation][:subject]
          if params[:series_statement][:periodical].to_s == "1"
            if @series_statement.root_manifestation
              @series_statement.root_manifestation.assign_attributes(params[:manifestation])
            else
              @series_statement.root_manifestation = Manifestation.new(params[:manifestation])
              @series_statement.root_manifestation.original_title = params[:series_statement][:original_title] if params[:series_statement][:original_title]
              @series_statement.root_manifestation.title_transcription = params[:series_statement][:title_transcription] if params[:series_statement][:title_transcription]
              @series_statement.root_manifestation.title_alternative = params[:series_statement][:title_alternative] if params[:series_statement][:title_alternative]
              @series_statement.root_manifestation.periodical_master = true
            end
            #TODO update position to edit patrons without destroy
            @series_statement.root_manifestation.creators.destroy_all; @series_statement.root_manifestation.creators     = Patron.add_patrons(@creator)
            @series_statement.root_manifestation.contributors.destroy_all; @series_statement.root_manifestation.contributors = Patron.add_patrons(@contributor)
            @series_statement.root_manifestation.publishers.destroy_all; @series_statement.root_manifestation.publishers   = Patron.add_patrons(@publisher) 
            @series_statement.root_manifestation.subjects     = Subject.import_subjects(@subject) 
            @series_statement.root_manifestation.save!
            @series_statement.manifestations << @series_statement.root_manifestation unless @series_statement.manifestations.include?(@series_statement.root_manifestation)
          else
            if @series_statement.root_manifestation && @series_statement.valid?
              @series_statement.root_manifestation.destroy
              @series_statement.root_manifestation = nil
            end
            @series_statement.periodical = false
          end
          @series_statement.save!
          @series_statement.manifestations.map { |manifestation| manifestation.index } if @series_statement.manifestations
          format.html { redirect_to @series_statement, :notice => t('controller.successfully_updated', :model => t('activerecord.models.series_statement')) }
          format.json { head :no_content }
        end
      rescue Exception => e
        logger.error "Failed to update: #{e}"
        @series_statement.root_manifestation = @series_statement.root_manifestation || Manifestation.new(params[:manifestation])
        prepare_options
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
  def prepare_options
    @carrier_types = CarrierType.all
    @manifestation_types = ManifestationType.where(:name => ['japanese_magazine', 'foreign_magazine', 'japanese_serial_book', 'foreign_serial_book'])
    @frequencies = Frequency.all
    @countries = Country.all
    @languages = Language.all_cache
    @roles = Role.all
  end
end
