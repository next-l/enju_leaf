# -*- encoding: utf-8 -*-
class LibrariesController < ApplicationController
  add_breadcrumb "I18n.t('page.configuration')", 'page_configuration_path'
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.library'))", 'libraries_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.library'))", 'new_library_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.library'))", 'edit_library_path(params[:id])', :only => [:edit, :update]
  add_breadcrumb "I18n.t('activerecord.models.library')", 'library_path(params[:id])', :only => [:show]
  load_and_authorize_resource
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]
  after_filter :solr_commit, :only => [:create, :update, :destroy]

  # GET /libraries
  # GET /libraries.json
  def index
    sort = {:sort_by => 'position', :order => 'asc'}

    case params[:sort_by]
    when 'name'
      sort[:sort_by] = 'display_name' 
    when 'created_at'
      sort[:sort_by] = 'created_at'
    end
    sort[:order] = 'desc' if params[:order] == 'desc'

    query = @query = params[:query].to_s.strip
    page = params[:page] || 1

    unless query.blank?
      @libraries = Library.search(:include => [:shelves]) do
        fulltext query
        paginate :page => page.to_i, :per_page => Library.default_per_page
      end.results
    else
      @libraries = Library.unscoped.order("#{sort[:sort_by]} #{sort[:order]}").page(page)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @libraries }
    end
  end

  # GET /libraries/1
  # GET /libraries/1.json
  def show
    if defined?(EnjuEvent)
      search = Sunspot.new_search(Event)
      library = @library.dup
      search.build do
        with(:library_id).equal_to library.id
        order_by(:start_at, :desc)
      end
      page = params[:event_page] || 1
      search.query.paginate(page.to_i, Event.default_per_page)
      @events = search.execute!.results
    end
    @shelves = @library.shelves.page(params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @library }
      format.js
    end
  end

  # GET /libraries/new
  def new
    @library = Library.new
    @library.country = LibraryGroup.site_config.country
    prepare_options

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @library }
    end
  end

  # GET /libraries/1/edit
  def edit
    prepare_options
  end

  # POST /libraries
  # POST /libraries.json
  def create
    #patron = Patron.create(:name => params[:library][:name], :patron_type => 'CorporateBody')
    @library = Library.new(params[:library])
    begin
      ActiveRecord::Base.transaction do
        @library.save!

        respond_to do |format|
          format.html { redirect_to @library, :notice => t('controller.successfully_created', :model => t('activerecord.models.library')) }
          format.json { render :json => @library, :status => :created }
        end
      end
    end
  rescue Exception => e
    logger.info "Error => #{e}"
    prepare_options
    @library.errors[:base] << t('library.already_exist_shelf') if @shelf_default and @shelf_default.errors.size > 0
    @library.errors[:base] << t('library.already_exist_shelf') if @shelf_in_process and @shelf_in_process.errors.size > 0
    respond_to do |format|
      format.html { render :action => "new" }
      format.json { render :json => @library.errors, :status => :unprocessable_entity }
    end
  end

  # PUT /libraries/1
  # PUT /libraries/1.json
  def update
    if params[:move]
      move_position(@library, params[:move])
      return
    end

    respond_to do |format|
      if @library.update_attributes(params[:library])
        format.html { redirect_to @library, :notice => t('controller.successfully_updated', :model => t('activerecord.models.library')) }
        format.json { head :no_content }
      else
        @library.name = @library.name_was
        prepare_options
        format.html { render :action => "edit" }
        format.json { render :json => @library.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /libraries/1
  # DELETE /libraries/1.json
  def destroy
    respond_to do |format|
      if @library.destroy?
        @library.shelves.each do |shelf|
          if shelf.destroy?
            shelf.destroy
          else
            flash[:message] = t('library.cannot_delete')
            format.html { redirect_to libraries_url }
            return
          end
        end
        @library.destroy
        format.html { redirect_to libraries_url }
        format.json { head :no_content }
      else
        flash[:message] = t('library.cannot_delete')
        format.html { redirect_to libraries_url }
      end
    end
  end

  private
  def prepare_options
    @library_groups = LibraryGroup.all
    @countries = Country.all_cache
  end
end
