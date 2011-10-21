class ResourceImportResultsController < InheritedResources::Base
  respond_to :html, :xml, :csv
  load_and_authorize_resource
  has_scope :file_id

  def index
    @resource_import_file = ResourceImportFile.where(:id => params[:resource_import_file_id]).first
    if @resource_import_file
      if params[:format] == 'csv'
        @resource_import_results = @resource_import_file.resource_import_results
      else
        @resource_import_results = @resource_import_file.resource_import_results.page(params[:page])
      end
    else
      @resource_import_results = @resource_import_results.page(params[:page])
    end
  end
end
