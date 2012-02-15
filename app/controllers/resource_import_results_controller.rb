class ResourceImportResultsController < InheritedResources::Base
  respond_to :html, :xml, :csv
  before_filter :access_denied, :except => [:index, :show]
  before_filter :check_client_ip_address
  load_and_authorize_resource
  has_scope :file_id

  def index
    @resource_import_file = ResourceImportFile.where(:id => params[:resource_import_file_id]).first
    @resource_import_results = @resource_import_file.resource_import_results if @resource_import_file
    @results_num = @resource_import_results.length
    @resource_import_results = @resource_import_results.page(params[:page]) unless params[:format] == 'tsv'

    if params[:format] == 'tsv'
      respond_to do |format|
        format.tsv { send_data ResourceImportResult.get_resource_import_results_tsv(@resource_import_results), :filename => configatron.resource_import_results_print_tsv.filename }
      end
    end
  end
end
