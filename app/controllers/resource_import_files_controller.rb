class ResourceImportFilesController < ApplicationController
  load_and_authorize_resource

  # GET /resource_import_files
  # GET /resource_import_files.json
  def index
    @resource_import_files = ResourceImportFile.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @resource_import_files }
    end
  end

  # GET /resource_import_files/1
  # GET /resource_import_files/1.json
  def show
    if @resource_import_file.resource_import.path
      unless configatron.uploaded_file.storage == :s3
        file = @resource_import_file.resource_import.path
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @resource_import_file }
      format.download {
        if configatron.uploaded_file.storage == :s3
          redirect_to @resource_import_file.resource_import.expiring_url(10)
        else
          send_file file, :filename => @resource_import_file.resource_import_file_name, :type => 'application/octet-stream'
        end
      }
    end
  end

  # GET /resource_import_files/new
  # GET /resource_import_files/new.json
  def new
    @resource_import_file = ResourceImportFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @resource_import_file }
    end
  end

  # GET /resource_import_files/1/edit
  def edit
  end

  # POST /resource_import_files
  # POST /resource_import_files.json
  def create
    @resource_import_file = ResourceImportFile.new(params[:resource_import_file])
    @resource_import_file.user = current_user

    respond_to do |format|
      if @resource_import_file.save
        format.html { redirect_to @resource_import_file, :notice => t('controller.successfully_created', :model => t('activerecord.models.resource_import_file')) }
        format.json { render :json => @resource_import_file, :status => :created, :location => @resource_import_file }
      else
        format.html { render :action => "new" }
        format.json { render :json => @resource_import_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /resource_import_files/1
  # PUT /resource_import_files/1.json
  def update
    respond_to do |format|
      if @resource_import_file.update_attributes(params[:resource_import_file])
        format.html { redirect_to @resource_import_file, :notice => t('controller.successfully_updated', :model => t('activerecord.models.resource_import_file')) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @resource_import_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /resource_import_files/1
  # DELETE /resource_import_files/1.json
  def destroy
    @resource_import_file.destroy

    respond_to do |format|
      format.html { redirect_to resource_import_files_url }
      format.json { head :no_content }
    end
  end
end
