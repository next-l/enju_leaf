class PatronImportResultsController < InheritedResources::Base
  respond_to :html, :json, :csv
  before_filter :check_client_ip_address
  before_filter :access_denied, :except => [:index, :show]
  load_and_authorize_resource
  has_scope :file_id

  def index
    @patron_import_file = PatronImportFile.where(:id => params[:patron_import_file_id]).first
    @patron_import_results = @patron_import_file.patron_import_results if @patron_import_file
    @results_num = @patron_import_results.length
    @patron_import_results = @patron_import_results.page(params[:page]) unless params[:format] == 'tsv'

    if params[:format] == 'tsv'
      respond_to do |format|
        format.tsv { send_data PatronImportResult.get_patron_import_results_tsv(@patron_import_results), :filename => configatron.patron_import_results_print_tsv.filename }
      end
    end
  end
end
