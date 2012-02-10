class ResourceImportTextresultsController < ApplicationController
  respond_to :html, :xml, :csv
  before_filter :access_denied, :except => [:index, :show]
  before_filter :check_client_ip_address
  load_and_authorize_resource
  has_scope :file_id

  def index
    @resource_import_textfile = ResourceImportTextfile.where(:id => params[:resource_import_textfile_id]).first
    if @resource_import_textfile
       @resource_import_textresults = @resource_import_textfile.resource_import_textresults.page(params[:page])
       @results_num = @resource_import_textfile.resource_import_textresults.length
    else
       @resource_import_textresults = @resource_import_textresults.page(params[:page])
       @results_num = @resource_import_textresults.length
    end
  end

end
