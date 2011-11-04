class PatronImportResultsController < InheritedResources::Base
  respond_to :html, :json, :csv
  load_and_authorize_resource
  has_scope :file_id
  actions :index, :show, :destroy

  def index
    @patron_import_file = PatronImportFile.where(:id => params[:patron_import_file_id]).first
    if @patron_import_file
      @patron_import_results = @patron_import_file.patron_import_results.page(params[:page])
    else
      @patron_import_results = @patron_import_results.page(params[:page])
    end
  end
end
