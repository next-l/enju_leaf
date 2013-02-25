class ShelvesController < ApplicationController
  add_breadcrumb "I18n.t('page.configuration')", 'page_configuration_path'
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.shelf'))", 'shelves_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.shelf'))", 'new_shelf_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.shelf'))", 'edit_shelf_path(params[:id])', :only => [:edit, :update]
  add_breadcrumb "I18n.t('activerecord.models.shelf')", 'shelf_path(params[:id])', :only => [:show]
  load_and_authorize_resource
  before_filter :get_library, :only => [:new, :edit, :create, :update, :output]
  before_filter :get_libraries, :only => [:new, :edit, :create, :update]
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /shelves
  # GET /shelves.json
  def index
    @count = {}
    page = params[:page] || 1

    # when create a item 
    if params[:mode] == 'select'
      if params[:library_id]
        library = Library.find(params[:library_id]) rescue nil
        if library
          @shelves = library.shelves
        else
          @shelves = Shelf.real
        end
      elsif params[:shelf_category]
        if params[:shelf_category] == 'other'
          sql = ""
          Shelf.categories.each do |c|
            next if c == 'other'
            sql << " AND " unless Shelf.categories.first == c
            sql << "display_name not like '#{c}%'"
          end
          @shelves = Shelf.where(sql)
        else
          @shelves = Shelf.where(["display_name like ?", params[:shelf_category] + '%'])
        end
      end
      render :partial => 'select_form'
      return
    end

    search_result = Shelf.search.build do
      with(:library).equal_to params[:library] if params[:library]
      with(:open_access).equal_to params[:open_access] if params[:open_access]
      if params[:format] == 'html' or params[:format].nil?
        facet :library
        facet :open_access
      end
      paginate :page => page.to_i, :per_page => Shelf.default_per_page
    end.execute rescue nil
    if params[:format].blank? or params[:format] == 'html'
      @library_facet = search_result.facet(:library).rows
      @open_access_facet = search_result.facet(:open_access).rows
    end
    @shelves = search_result.results
    @count[:query_result] = @shelves.total_entries
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
    @shelf = Shelf.new
  end

  # GET /shelves/1/edit
  def edit
  end

  # POST /shelves
  # POST /shelves.json
  def create
    @shelf = Shelf.new(params[:shelf])

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
    respond_to do |format|
      if @shelf.update_attributes(params[:shelf])
        format.html { redirect_to @shelf, :notice => t('controller.successfully_updated', :model => t('activerecord.models.shelf')) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @shelf.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shelves/1
  # DELETE /shelves/1.json
  def destroy
    if @shelf.id == 1 or @shelf.open_access == 9
      access_denied; return
    end

    respond_to do |format|
      if @shelf.destroy?
        @shelf.destroy
        format.html { redirect_to shelves_url }
        format.json { head :no_content }
      else
        flash[:message] = t('shelf.cannot_delete')
        format.html { redirect_to shelves_url }
      end
    end
  end

  def output
    @item = Item.find(params[:item])
    file = Shelf.get_closing_report(@item)
    send_data file, :filename => "closed_shelf.pdf", :type => 'application/pdf', :disposition => 'attachment'
  end
end
