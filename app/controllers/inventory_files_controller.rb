class InventoryFilesController < ApplicationController
  before_action :set_inventory_file, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :prepare_options, only: [:new, :edit]

  # GET /inventory_files
  # GET /inventory_files.json
  def index
    @inventory_files = InventoryFile.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /inventory_files/1
  # GET /inventory_files/1.json
  def show
    @inventories = @inventory_file.inventories.page(params[:page])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /inventory_files/new
  def new
    @inventory_file = InventoryFile.new
  end

  # GET /inventory_files/1/edit
  def edit
  end

  # POST /inventory_files
  # POST /inventory_files.json
  def create
    @inventory_file = InventoryFile.new(inventory_file_params)
    @inventory_file.user = current_user

    respond_to do |format|
      if @inventory_file.save
        flash[:notice] = t('controller.successfully_created', model: t('activerecord.models.inventory_file'))
        @inventory_file.import
        format.html { redirect_to(@inventory_file) }
        format.json { render json: @inventory_file, status: :created, location: @inventory_file }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @inventory_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /inventory_files/1
  # PUT /inventory_files/1.json
  def update
    respond_to do |format|
      if @inventory_file.update(inventory_file_params)
        flash[:notice] = t('controller.successfully_updated', model: t('activerecord.models.inventory_file'))
        format.html { redirect_to(@inventory_file) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @inventory_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_files/1
  # DELETE /inventory_files/1.json
  def destroy
    @inventory_file.destroy

    respond_to do |format|
      format.html { redirect_to inventory_files_url }
      format.json { head :no_content }
    end
  end

  private
  def set_inventory_file
    @inventory_file = InventoryFile.find(params[:id])
    authorize @inventory_file
  end

  def check_policy
    authorize InventoryFile
  end

  def prepare_options
    @libraries = Library.order(:position)
    @shelves = Shelf.order(:position)
  end

  def inventory_file_params
    params.require(:inventory_file).permit(:attachment, :shelf_id, :note)
  end
end
