class InventoryFilesController < ApplicationController
  load_and_authorize_resource

  # GET /inventory_files
  # GET /inventory_files.json
  def index
    @inventory_files = InventoryFile.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @inventory_files }
    end
  end

  # GET /inventory_files/1
  # GET /inventory_files/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @inventory_file }
    end
  end

  # GET /inventory_files/new
  # GET /inventory_files/new.json
  def new
    @inventory_file = InventoryFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @inventory_file }
    end
  end

  # GET /inventory_files/1/edit
  def edit
  end

  # POST /inventory_files
  # POST /inventory_files.json
  def create
    @inventory_file = InventoryFile.new(params[:inventory_file])
    @inventory_file.user = current_user

    respond_to do |format|
      if @inventory_file.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.inventory_file'))
        @inventory_file.import
        format.html { redirect_to(@inventory_file) }
        format.json { render :json => @inventory_file, :status => :created, :location => @inventory_file }
      else
        format.html { render :action => "new" }
        format.json { render :json => @inventory_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /inventory_files/1
  # PUT /inventory_files/1.json
  def update
    respond_to do |format|
      if @inventory_file.update_attributes(params[:inventory_file])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.inventory_file'))
        format.html { redirect_to(@inventory_file) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @inventory_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_files/1
  # DELETE /inventory_files/1.json
  def destroy
    @inventory_file.destroy

    respond_to do |format|
      format.html { redirect_to(inventory_files_url) }
      format.json { head :no_content }
    end
  end
end
