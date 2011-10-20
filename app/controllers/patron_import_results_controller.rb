class PatronImportResultsController < InheritedResources::Base
  respond_to :html, :xml, :csv
  before_filter :check_client_ip_address
  before_filter :access_denied, :except => [:index, :show]
  load_and_authorize_resource
  has_scope :file_id

  def index
    @patron_import_file = PatronImportFile.where(:id => params[:patron_import_file_id]).first
    if @patron_import_file
      @patron_import_results = @patron_import_file.patron_import_results.page(params[:page])
      @results_num = @patron_import_file.patron_import_results.length
    else
      @patron_import_results = @patron_import_results.page(params[:page])
      @results_num = @patron_import_results.length
    end
  end
end
