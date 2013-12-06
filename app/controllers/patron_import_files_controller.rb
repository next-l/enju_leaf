class PatronImportFilesController < ApplicationController
  add_breadcrumb "I18n.t('page.import_from_file')", 'page_import_path'
  add_breadcrumb "I18n.t('activerecord.models.patron_import_file')", 'patron_import_files_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.patron_import_file'))", 'new_patron_import_file_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.patron_import_file'))", 'edit_patron_import_file_path(params[:id])', :only => [:edit, :update]
  before_filter :check_client_ip_address
  load_and_authorize_resource

  # GET /patron_import_files
  # GET /patron_import_files.json
  def index
    @patron_import_files = PatronImportFile.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @patron_import_files }
    end
  end

  # GET /patron_import_files/1
  # GET /patron_import_files/1.json
  def show
    if @patron_import_file.patron_import.path
      unless Setting.uploaded_file.storage == :s3
        file = @patron_import_file.patron_import.path
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @patron_import_file }
      format.download {
        if Setting.uploaded_file.storage == :s3
          redirect_to @patron_import_file.patron_import.expiring_url(10)
        else
          send_file file, :filename => @patron_import_file.patron_import_file_name, :type => 'application/octet-stream'
        end
      }
    end
  end

  # GET /patron_import_files/new
  # GET /patron_import_files/new.json
  def new
    @patron_import_file = PatronImportFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @patron_import_file }
    end
  end

  # GET /patron_import_files/1/edit
  def edit
  end

  # POST /patron_import_files
  # POST /patron_import_files.json
  def create
    @patron_import_file = PatronImportFile.new(params[:patron_import_file])
    @patron_import_file.user = current_user

    respond_to do |format|
      if @patron_import_file.save
        format.html { redirect_to @patron_import_file, :notice => t('controller.successfully_created', :model => t('activerecord.models.patron_import_file')) }
        format.json { render :json => @patron_import_file, :status => :created, :location => @patron_import_file }
      else
        format.html { render :action => "new" }
        format.json { render :json => @patron_import_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /patron_import_files/1
  # PUT /patron_import_files/1.json
  def update
    respond_to do |format|
      if @patron_import_file.update_attributes(params[:patron_import_file])
        format.html { redirect_to @patron_import_file, :notice => t('controller.successfully_updated', :model => t('activerecord.models.patron_import_file')) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @patron_import_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /patron_import_files/1
  # DELETE /patron_import_files/1.json
  def destroy
    @patron_import_file.destroy

    respond_to do |format|
      format.html { redirect_to(patron_import_files_url) }
      format.json { head :no_content }
    end
  end

  def import_request
    begin
      @patron_import_file = PatronImportFile.find(params[:id])
      Asynchronized_Service.new.perform(:PatronImportFile_import, @patron_import_file.id)
      flash[:message] = t('patron_import_file.start_importing')
    rescue Exception => e
      logger.error "Failed to send process to delayed_job: #{e}"
    end
    respond_to do |format|
      format.html {redirect_to(patron_import_file_patron_import_results_path(@patron_import_file))}
    end
  end


end
