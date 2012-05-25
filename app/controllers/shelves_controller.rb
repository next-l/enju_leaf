class ShelvesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_library
  before_filter :get_libraries, :only => [:new, :edit, :create, :update]
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /shelves
  # GET /shelves.json
  def index
    if params[:mode] == 'select'
      if @library
        @shelves = @library.shelves
      else
        @shelves = Shelf.real
      end
      render :partial => 'select_form'
      return
    else
      sort = {:sort_by => 'name', :order => 'asc'}
      #case params[:sort_by]
      #when 'name'
      #  sort[:sort_by] = 'name'
      #end
      sort[:order] = 'desc' if params[:order] == 'desc'

      query = @query = params[:query].to_s.strip
      page = params[:page] || 1
      library = @library if @library

      search = Shelf.search(:include => [:library]) do
        fulltext query if query.present?
        paginate :page => page.to_i, :per_page => Shelf.per_page
        if library
          with(:library).equal_to library.name
          order_by :position, :asc
        end
        order_by sort[:sort_by], sort[:order]
        facet :library
      end
      @shelves = search.results
      @library_facet = search.facet(:library).rows
      @library_names = Library.select(:name).collect(&:name)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @shelves }
    end
  end

  # GET /shelves/1
  # GET /shelves/1.json
  def show
    @shelf = Shelf.find(params[:id], :include => :library)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @shelf }
    end
  end

  # GET /shelves/new
  # GET /shelves/new.json
  def new
    @library = Library.web if @library.nil?
    @shelf = Shelf.new
    @shelf.library = @library
    #@shelf.user = current_user

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @shelf }
    end
  end

  # GET /shelves/1/edit
  def edit
    @shelf = Shelf.find(params[:id], :include => :library)
  end

  # POST /shelves
  # POST /shelves.json
  def create
    @shelf = Shelf.new(params[:shelf])
    if @library
      @shelf.library = @library
    else
      @shelf.library = Library.web #unless current_user.has_role?('Librarian')
    end

    respond_to do |format|
      if @shelf.save
        format.html { redirect_to @shelf, :notice => t('controller.successfully_created', :model => t('activerecord.models.shelf')) }
        format.json { render :json => @shelf, :status => :created, :location => @shelf }
      else
        @library = Library.first if @shelf.library.nil?
        format.html { render :action => "new" }
        format.json { render :json => @shelf.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shelves/1
  # PUT /shelves/1.json
  def update
    @shelf.library = @library if @library

    if params[:move]
      move_position(@shelf, params[:move], false)
      redirect_to library_shelves_url(@shelf.library)
      return
    end

    respond_to do |format|
      if @shelf.update_attributes(params[:shelf])
        format.html { redirect_to @shelf, :notice => t('controller.successfully_updated', :model => t('activerecord.models.shelf')) }
        format.json { head :no_content }
      else
        @library = Library.first if @library.nil?
        format.html { render :action => "edit" }
        format.json { render :json => @shelf.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shelves/1
  # DELETE /shelves/1.json
  def destroy
    if @shelf.id == 1
      access_denied; return
    end
    @shelf.destroy

    respond_to do |format|
      format.html { redirect_to shelves_url }
      format.json { head :no_content }
    end
  end
end
