class ResourceImportResultsController < InheritedResources::Base
  respond_to :html, :xml#, :csv
  before_filter :access_denied, :except => [:index, :show]
  before_filter :check_client_ip_address
  load_and_authorize_resource
  has_scope :file_id

  def index
    @resource_import_file = ResourceImportFile.where(:id => params[:resource_import_file_id]).first
    if @resource_import_file
      @resource_import_results = @resource_import_file.resource_import_results
      @results_num = @resource_import_file.resource_import_results.length
    else
      @results_num = @resource_import_results.length
    end
    if params[:output_tsv]
      data = ResourceImportResult.get_resource_import_results_tsv(@resource_import_results)
      send_data data, :filename => configatron.resource_import_results_print_tsv.filename
      return
    else
      @resource_import_results = @resource_import_results.page(params[:page])
    end
  end
end
