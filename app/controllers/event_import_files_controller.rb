class EventImportFilesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  # GET /event_import_files
  # GET /event_import_files.json
  def index
    @event_import_files = EventImportFile.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @event_import_files }
    end
  end

  # GET /event_import_files/1
  # GET /event_import_files/1.json
  def show
    if @event_import_file.event_import.path
      unless Setting.uploaded_file.storage == :s3
        file = @event_import_file.event_import.path
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @event_import_file }
      format.download {
        if Setting.uploaded_file.storage == :s3
          redirect_to @event_import_file.event_import.expiring_url(10)
        else
          send_file file, :filename => @event_import_file.event_import_file_name, :type => 'application/octet-stream'
        end
      }
    end
  end

  # GET /event_import_files/new
  # GET /event_import_files/new.json
  def new
    @event_import_file = EventImportFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @event_import_file }
    end
  end

  # GET /event_import_files/1/edit
  def edit
  end

  # POST /event_import_files
  # POST /event_import_files.json
  def create
    @event_import_file = EventImportFile.new(params[:event_import_file])
    @event_import_file.user = current_user

    respond_to do |format|
      if @event_import_file.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.event_import_file'))
        format.html { redirect_to(@event_import_file) }
        format.json { render :json => @event_import_file, :status => :created, :location => @event_import_file }
      else
        format.html { render :action => "new" }
        format.json { render :json => @event_import_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /event_import_files/1
  # PUT /event_import_files/1.json
  def update
    respond_to do |format|
      if @event_import_file.update_attributes(params[:event_import_file])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.event_import_file'))
        format.html { redirect_to(@event_import_file) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @event_import_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /event_import_files/1
  # DELETE /event_import_files/1.json
  def destroy
    @event_import_file.destroy

    respond_to do |format|
      format.html { redirect_to(event_import_files_url) }
      format.json { head :no_content }
    end
  end

  def import_request
    begin
      @event_import_file = EventImportFile.find(params[:id])
      Asynchronized_Service.new.perform(:EventImportFile_import, @event_import_file.id)
      flash[:message] = t('event_import_file.start_importing')
    rescue Exception => e
      logger.error "Failed to send process to delayed_job: #{e}"
    end
    respond_to do |format|
      format.html {redirect_to(event_import_file_event_import_results_path(@event_import_file))}
    end
  end

end
