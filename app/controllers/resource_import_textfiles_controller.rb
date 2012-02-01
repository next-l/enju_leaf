class ResourceImportTextfilesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
    
  def index
    @resource_import_textfiles = ResourceImportTextfile.page(params[:page])
  end

  def new
    @resource_import_textfile = ResourceImportTextfile.new
  end

  def create
    @resource_import_textfile = ResourceImportTextfile.new(params[:resource_import_textfile])
    @resource_import_textfile.user = current_user

    respond_to do |format|
      if @resource_import_textfile.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.resource_import_textfile'))
        format.html { redirect_to(@resource_import_textfile) }
        format.xml  { render :xml => @resource_import_textfile, :status => :created, :location => @resource_import_textfile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resource_import_textfile.errors, :status => :unprocessable_entity }
      end
    end
  end
end
