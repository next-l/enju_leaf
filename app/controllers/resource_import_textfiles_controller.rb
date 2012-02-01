class ResourceImportTextfilesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
    
  def index
    @resource_import_files = ResourceImportFile.page(params[:page])
  end

  def new
    @resource_import_file = ResourceImportFile.new
    @file_path = root_url + configatron.resource_import_template
  end

  def create
    @resource_import_file = ResourceImportFile.new(params[:resource_import_file])
    @resource_import_file.user = current_user
  end
end
