# -*- encoding: utf-8 -*-
class LibrariesController < ApplicationController
  load_and_authorize_resource
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]
  after_filter :solr_commit, :only => [:create, :update, :destroy]

  # GET /libraries
  # GET /libraries.xml
  def index
    sort = {:sort_by => 'position', :order => 'asc'}
    case params[:sort_by]
    when 'name'
      sort[:sort_by] = 'name'
    end
    sort[:order] = 'desc' if params[:order] == 'desc'

    query = @query = params[:query].to_s.strip
    page = params[:page] || 1

    if query.present?
      begin
        @libraries = Library.search(:include => [:shelves]) do
          fulltext query
          paginate :page => page.to_i, :per_page => Tag.per_page
          order_by sort[:sort_by], sort[:order]
        end.results
      rescue RSolr::RequestError
        @libraries = WillPaginate::Collection.create(1,1,0) do end
      end
    else
      @libraries = Library.paginate(:page => page, :order => "#{sort[:sort_by]} #{sort[:order]}")
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @libraries }
    end
  rescue RSolr::RequestError
    flash[:notice] = t('page.error_occured')
    redirect_to libraries_url
    return
  end

  # GET /libraries/1
  # GET /libraries/1.xml
  def show
    @library = Library.first(:conditions => {:name => params[:id]}, :include => :shelves)
    raise ActiveRecord::RecordNotFound if @library.nil?

    search = Sunspot.new_search(Event)
    library = @library.dup
    search.build do
      with(:library_id).equal_to library.id
      order_by(:start_at, :desc)
    end
    page = params[:event_page] || 1
    search.query.paginate(page.to_i, Event.per_page)
    begin
      @events = search.execute!.results
    rescue RSolr::RequestError
      @events = WillPaginate::Collection.create(1,1,0) do end
    end

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @library }
      format.js
    end
  end

  # GET /libraries/new
  def new
    #@patron = Patron.find(params[:patron_id]) rescue nil
    #unless @patron
    #  flash[:notice] = ('Specify patron id.')
    #  redirect_to patrons_url
    #  return
    #end
    @library = Library.new
    @library.country = LibraryGroup.site_config.country
    prepare_options
  end

  # GET /libraries/1;edit
  def edit
    @library = Library.first(:conditions => {:name => params[:id]})
    raise ActiveRecord::RecordNotFound if @library.nil?
    prepare_options
  end

  # POST /libraries
  # POST /libraries.xml
  def create
    #patron = Patron.create(:name => params[:library][:name], :patron_type => 'CorporateBody')
    @library = Library.new(params[:library])

    respond_to do |format|
      if @library.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.library'))
        format.html { redirect_to(@library) }
        format.xml  { render :xml => @library, :status => :created }
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @library.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /libraries/1
  # PUT /libraries/1.xml
  def update
    @library = Library.first(:conditions => {:name => params[:id]})
    raise ActiveRecord::RecordNotFound if @library.nil?

    if @library and params[:position]
      @library.insert_at(params[:position])
      redirect_to libraries_url
      return
    end

    respond_to do |format|
      if @library.update_attributes(params[:library])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.library'))
        format.html { redirect_to library_url(@library.name) }
        format.xml  { head :ok }
      else
        @library.name = @library.name_was
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @library.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /libraries/1
  # DELETE /libraries/1.xml
  def destroy
    @library = Library.first(:conditions => {:name => params[:id]})
    raise ActiveRecord::RecordNotFound if @library.blank?
    raise if @library.web?

    @library.destroy

    respond_to do |format|
      format.html { redirect_to libraries_url }
      format.xml  { head :ok }
    end
  rescue
    access_denied
  end

  private
  def prepare_options
    @library_groups = LibraryGroup.all
    @countries = Country.all
  end
end
