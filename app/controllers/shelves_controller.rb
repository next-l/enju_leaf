class ShelvesController < ApplicationController
  before_action :set_shelf, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_library
  before_action :get_libraries, only: [:new, :edit, :create, :update]

  # GET /shelves
  # GET /shelves.json
  def index
    if params[:mode] == 'select'
      if @library
        @shelves = @library.shelves
      else
        @shelves = Shelf.real.order(:position)
      end
      render partial: 'select_form'
      return
    else
      sort = {sort_by: 'shelf_name', order: 'asc'}
      # case params[:sort_by]
      # when 'name'
      #  sort[:sort_by] = 'name'
      # end
      sort[:order] = 'desc' if params[:order] == 'desc'

      query = @query = params[:query].to_s.strip
      page = params[:page] || 1
      library = @library if @library

      search = Shelf.search(include: [:library]) do
        fulltext query if query.present?
        paginate page: page.to_i, per_page: Shelf.default_per_page
        if library
          with(:library).equal_to library.name
          order_by :position, :asc
        else
          order_by sort[:sort_by], sort[:order]
        end
        facet :library
      end
      @shelves = search.results
      @library_facet = search.facet(:library).rows
      @library_names = Library.pluck(:name)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shelves }
    end
  end

  # GET /shelves/1
  # GET /shelves/1.json
  def show
    @shelf = Shelf.includes(:library).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @shelf }
      format.html.phone
    end
  end

  # GET /shelves/new
  # GET /shelves/new.json
  def new
    @shelf = Shelf.new
    @library ||= current_user.profile.library
    @shelf.library = @library
    # @shelf.user = current_user

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shelf }
    end
  end

  # GET /shelves/1/edit
  def edit
    @shelf = Shelf.includes(:library).find(params[:id])
  end

  # POST /shelves
  # POST /shelves.json
  def create
    @shelf = Shelf.new(shelf_params)
    if @library
      @shelf.library = @library
    else
      @shelf.library = Library.web # unless current_user.has_role?('Librarian')
    end

    respond_to do |format|
      if @shelf.save
        format.html { redirect_to @shelf, notice: t('controller.successfully_created', model: t('activerecord.models.shelf')) }
        format.json { render json: @shelf, status: :created, location: @shelf }
      else
        @library = Library.first if @shelf.library.nil?
        format.html { render action: "new" }
        format.json { render json: @shelf.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /shelves/1
  # PUT /shelves/1.json
  def update
    @shelf.library = @library if @library

    if params[:move]
      move_position(@shelf, params[:move], false)
      redirect_to shelves_url(library_id: @shelf.library_id)
      return
    end

    respond_to do |format|
      if @shelf.update(shelf_params)
        format.html { redirect_to @shelf, notice: t('controller.successfully_updated', model: t('activerecord.models.shelf')) }
        format.json { head :no_content }
      else
        @library = Library.first if @library.nil?
        format.html { render action: "edit" }
        format.json { render json: @shelf.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shelves/1
  # DELETE /shelves/1.json
  def destroy
    @shelf.destroy

    respond_to do |format|
      format.html { redirect_to shelves_url }
      format.json { head :no_content }
    end
  end

  private

  def set_shelf
    @shelf = Shelf.find(params[:id])
    authorize @shelf
  end

  def check_policy
    authorize Shelf
  end

  def shelf_params
    params.require(:shelf).permit(
      :name, :display_name, :note, :library_id, :closed
    )
  end
end
