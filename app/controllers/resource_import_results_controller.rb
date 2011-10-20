class ResourceImportResultsController < InheritedResources::Base
  respond_to :html, :xml, :csv
  before_filter :access_denied, :except => [:index, :show]
  before_filter :check_client_ip_address
  load_and_authorize_resource
  has_scope :file_id

  def index
    @resource_import_file = ResourceImportFile.where(:id => params[:resource_import_file_id]).first
    if @resource_import_file
      @resource_import_results = @resource_import_file.resource_import_results.page(params[:page])
      @results_num = @resource_import_file.resource_import_results.length
    else
      @resource_import_results = @resource_import_results.page(params[:page])
      @results_num = @resource_import_results.length
    end
  end
end
