class ResourceImportTextresultsController < ApplicationController
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.resource_import_textresult'))", 'resource_import_textfile_resource_import_textresults_path(params[:resource_import_textfile_id])'
  respond_to :html, :json, :csv
  before_filter :access_denied, :except => [:index, :show]
  before_filter :check_client_ip_address
  load_and_authorize_resource
  has_scope :file_id

  def index
    @resource_import_textfile = ResourceImportTextfile.where(:id => params[:resource_import_textfile_id]).first
    if @resource_import_textfile
      if params[:only_error]
        @resource_import_textresults = @resource_import_textfile.resource_import_textresults.where(:failed => true)
      else
        @resource_import_textresults = @resource_import_textfile.resource_import_textresults
      end
    end
    @results_num = @resource_import_textresults.length
    unless params[:format] == 'tsv' or params[:format] == 'xlsx'
      @resource_import_textresults = @resource_import_textresults.page(params[:page])
    end

    respond_to do |format|
      format.tsv  { send_data ResourceImportTextresult.get_resource_import_textresults_tsv(@resource_import_textresults), :filename => Setting.resource_import_textresults_print_tsv.filename}
      format.xlsx { send_file ResourceImportTextresult.get_resource_import_textresults_excelx(@resource_import_textresults), :filename => Setting.resource_import_textresults_print_xlsx.filename; return}
      format.html
    end
  end
end
