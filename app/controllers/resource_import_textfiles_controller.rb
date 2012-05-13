class ResourceImportTextfilesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
    
  def index
    @resource_import_textfiles = ResourceImportTextfile.page(params[:page])
  end

  def new
    @resource_import_textfile = ResourceImportTextfile.new
    @adapters = EnjuTrunk::ResourceAdapter::Base.default
  end

  def show
    if @resource_import_textfile.resource_import_text.path
      file = @resource_import_textfile.resource_import_text.path
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @resource_import_textfile }
      format.download {
        send_file file, :filename => @resource_import_textfile.resource_import_text_file_name, :type => 'application/octet-stream'
      }
    end
  end

  def create
    @resource_import_textfile = ResourceImportTextfile.new(params[:resource_import_textfile])
    @resource_import_textfile.user = current_user

    respond_to do |format|
      if @resource_import_textfile.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.resource_import_textfile'))
        format.html { redirect_to(@resource_import_textfile) }
        format.json { render :json => @resource_import_textfile, :status => :created, :location => @resource_import_textfile }
      else
        @adapters = EnjuTrunk::ResourceAdapter::Base.all
        format.html { render :action => "new" }
        format.json { render :json => @resource_import_textfile.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @resource_import_textfile.destroy

    respond_to do |format|
      format.html { redirect_to(resource_import_textfiles_url) }
      format.json { head :no_content }
    end
  end

  def import_request
    @resource_import_textfile = ResourceImportTextfile.find(params[:id])
    #ResourceImportTextfile.send_later(:import, @resource_import_textfile.id, 0)
    Asynchronized_Service.new.delay.perform(:ResoureceImportTextfile_import, @resource_import_textfile.id)
    flash[:message] = t('resource_import_textfile.start_importing')
    respond_to do |format|
      format.html {redirect_to(resource_import_textfile_resource_import_textresults_path(@resource_import_textfile))}
    end
  end

end
