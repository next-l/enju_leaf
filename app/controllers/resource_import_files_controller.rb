class ResourceImportFilesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  # GET /resource_import_files
  # GET /resource_import_files.xml
  def index
    @resource_import_files = ResourceImportFile.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @resource_import_files }
    end
  end

  # GET /resource_import_files/1
  # GET /resource_import_files/1.xml
  def show
    @resource_import_file = ResourceImportFile.find(params[:id])
    @imported_objects = @resource_import_file.imported_objects.paginate(:page => params[:object_page], :per_page => ImportedObject.per_page)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @resource_import_file }
      format.download  { send_file @resource_import_file.resource_import.path, :filename => @resource_import_file.resource_import_file_name, :type => @resource_import_file.resource_import_content_type, :disposition => 'inline' }
      format.js
    end
  end

  # GET /resource_import_files/new
  # GET /resource_import_files/new.xml
  def new
    @resource_import_file = ResourceImportFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resource_import_file }
    end
  end

  # GET /resource_import_files/1/edit
  def edit
    @resource_import_file = ResourceImportFile.find(params[:id])
  end

  # POST /resource_import_files
  # POST /resource_import_files.xml
  def create
    @resource_import_file = ResourceImportFile.new(params[:resource_import_file])
    @resource_import_file.user = current_user
    #@resource_import_file.file_hash = Digest::SHA1.hexdigest(params[:resource_import_file][:uploaded_data])

    respond_to do |format|
      if @resource_import_file.save
        # TODO: 他の形式
        #num = @resource_import_file.import_csv
        #flash[:notice] = n('%{num} resource is imported.', '%{num} resources are imported', num) % {:num => num}
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.resource_import_file'))
        #flash[:notice] << t('import.will_be_imported', :minute => 60).to_s # TODO: インポートまでの時間表記

        #@resource_import_file.import
        format.html { redirect_to(@resource_import_file) }
        format.xml  { render :xml => @resource_import_file, :status => :created, :location => @resource_import_file }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resource_import_file.errors, :status => :unprocessable_entity }
      end
    end
  #rescue
  #  flash[:notice] = ('Invalid file.')
  #  redirect_to new_resource_import_file_url
  end

  # PUT /resource_import_files/1
  # PUT /resource_import_files/1.xml
  def update
    @resource_import_file = ResourceImportFile.find(params[:id])

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
    @resource_import_file = ResourceImportFile.find(params[:id])
    @resource_import_file.destroy

    respond_to do |format|
      format.html { redirect_to(resource_import_files_url) }
      format.xml  { head :ok }
    end
  end
end
