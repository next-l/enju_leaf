class EventImportFilesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  # GET /event_import_files
  # GET /event_import_files.xml
  def index
    @event_import_files = EventImportFile.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @event_import_files }
    end
  end

  # GET /event_import_files/1
  # GET /event_import_files/1.xml
  def show
    @event_import_file = EventImportFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event_import_file }
      format.download  { send_file @event_import_file.event_import.path, :filename => @event_import_file.event_import_file_name, :type => @event_import_file.event_import_content_type, :disposition => 'inline' }
    end
  end

  # GET /event_import_files/new
  # GET /event_import_files/new.xml
  def new
    @event_import_file = EventImportFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event_import_file }
    end
  end

  # GET /event_import_files/1/edit
  def edit
    @event_import_file = EventImportFile.find(params[:id])
  end

  # POST /event_import_files
  # POST /event_import_files.xml
  def create
    @event_import_file = EventImportFile.new(params[:event_import_file])
    @event_import_file.user = current_user

    respond_to do |format|
      if @event_import_file.save!
        #flash[:notice] = n('%{num} event is imported.', '%{num} events are imported.', num) % {:num => num[:success]}
        #flash[:notice] += n('%{num} event is imported.', '%{num} events are imported.', num) % {:num => num[:failure]} if num[:failure] > 0
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.event_import_file'))
        #flash[:notice] << t('import.will_be_imported', :minute => 60).to_s # TODO: インポートまでの時間表記
        #@event_import_file.import
        format.html { redirect_to(@event_import_file) }
        format.xml  { render :xml => @event_import_file, :status => :created, :location => @event_import_file }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event_import_file.errors, :status => :unprocessable_entity }
      end
    end
  #rescue
  #  flash[:notice] = t('attachment_file.invalid_file')
  #  redirect_to new_event_import_file_url
  end

  # PUT /event_import_files/1
  # PUT /event_import_files/1.xml
  def update
    @event_import_file = EventImportFile.find(params[:id])

    respond_to do |format|
      if @event_import_file.update_attributes(params[:event_import_file])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.event_import_file'))
        format.html { redirect_to(@event_import_file) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event_import_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /event_import_files/1
  # DELETE /event_import_files/1.xml
  def destroy
    @event_import_file = EventImportFile.find(params[:id])
    @event_import_file.destroy

    respond_to do |format|
      format.html { redirect_to(event_import_files_url) }
      format.xml  { head :ok }
    end
  end
end
