class ResourceImportTextresultsController < ApplicationController
  respond_to :html, :json, :csv
  before_filter :access_denied, :except => [:index, :show]
  before_filter :check_client_ip_address
  load_and_authorize_resource
  has_scope :file_id

  def index
    @resource_import_textfile = ResourceImportTextfile.where(:id => params[:resource_import_textfile_id]).first
    @resource_import_textresults = @resource_import_textfile.resource_import_textresults if @resource_import_textfile
    @results_num = @resource_import_textresults.length
    @resource_import_textresults = @resource_import_textresults.page(params[:page]) unless params[:format] == 'tsv'

    if params[:format] == 'tsv'
      respond_to do |format|
        format.tsv { send_data ResourceImportTextresult.get_resource_import_textresults_tsv(@resource_import_textresults), :filename => configatron.resource_import_textresults_print_tsv.filename}
      end
    end
  end
end
