class ResourceImportFilesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  # GET /resource_import_files
  # GET /resource_import_files.xml
  def index
    @resource_import_files = ResourceImportFile.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @resource_import_files }
    end
  end

  # GET /resource_import_files/1
  # GET /resource_import_files/1.xml
  def show
    if @resource_import_file.resource_import.path
      unless configatron.uploaded_file.storage == :s3
        file = @resource_import_file.resource_import.path
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @resource_import_file }
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
  # GET /resource_import_files/new.xml
  def new
    @resource_import_file = ResourceImportFile.new
    @file_path = root_url + configatron.resource_import_template
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resource_import_file }
    end
  end

  # GET /resource_import_files/1/edit
  def edit
  end

  # POST /resource_import_files
  # POST /resource_import_files.xml
  def create
    @resource_import_file = ResourceImportFile.new(params[:resource_import_file])
    @resource_import_file.user = current_user

    respond_to do |format|
      if @resource_import_file.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.resource_import_file'))
        format.html { redirect_to(@resource_import_file) }
        format.xml  { render :xml => @resource_import_file, :status => :created, :location => @resource_import_file }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resource_import_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /resource_import_files/1
  # PUT /resource_import_files/1.xml
  def update
    respond_to do |format|
      if @resource_import_file.update_attributes(params[:resource_import_file])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.resource_import_file'))
        format.html { redirect_to(@resource_import_file) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @resource_import_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /resource_import_files/1
  # DELETE /resource_import_files/1.xml
  def destroy
    @resource_import_file.destroy

    respond_to do |format|
      format.html { redirect_to(resource_import_files_url) }
      format.xml  { head :ok }
    end
  end

  def import_request
    begin
      @resource_import_file = ResourceImportFile.find(params[:id])
      ResourceImportFile.send_later(:import, @resource_import_file.id, 0)
      flash[:message] = t('resource_import_file.start_importing')
    rescue Exception => e
      logger.error "Failed to send process to delayed_job: #{e}"
    end 
    respond_to do |format|
      format.html {redirect_to(resource_import_file_resource_import_results_path(@resource_import_file))}
    end
  end
end
