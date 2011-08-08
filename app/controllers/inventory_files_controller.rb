class InventoryFilesController < ApplicationController
  load_and_authorize_resource

  # GET /inventory_files
  # GET /inventory_files.xml
  def index
    @inventory_files = InventoryFile.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inventory_files }
    end
  end

  # GET /inventory_files/1
  # GET /inventory_files/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @inventory_file }
    end
  end

  # GET /inventory_files/new
  # GET /inventory_files/new.xml
  def new
    @inventory_file = InventoryFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @inventory_file }
    end
  end

  # GET /inventory_files/1/edit
  def edit
  end

  # POST /inventory_files
  # POST /inventory_files.xml
  def create
    @inventory_file = InventoryFile.new(params[:inventory_file])
    @inventory_file.user = current_user

    respond_to do |format|
      if @inventory_file.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.inventory_file'))
        @inventory_file.import
        format.html { redirect_to(@inventory_file) }
        format.xml  { render :xml => @inventory_file, :status => :created, :location => @inventory_file }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @inventory_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /inventory_files/1
  # PUT /inventory_files/1.xml
  def update
    respond_to do |format|
      if @inventory_file.update_attributes(params[:inventory_file])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.inventory_file'))
        format.html { redirect_to(@inventory_file) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @inventory_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_files/1
  # DELETE /inventory_files/1.xml
  def destroy
    @inventory_file.destroy

    respond_to do |format|
      format.html { redirect_to(inventory_files_url) }
      format.xml  { head :ok }
    end
  end
end
