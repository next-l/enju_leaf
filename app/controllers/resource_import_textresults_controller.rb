class ResourceImportTextresultsController < ApplicationController
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.resource_import_textresult'))", 'new_resource_import_textresult_path([:id])'
  respond_to :html, :json, :csv
  before_filter :access_denied, :except => [:index, :show]
  before_filter :check_client_ip_address
  load_and_authorize_resource
  has_scope :file_id

  def index
    @resource_import_textfile = ResourceImportTextfile.where(:id => params[:resource_import_textfile_id]).first
    if @resource_import_textfile
      if params[:only_error]
        @resource_import_textresults = @resource_import_textfile.resource_import_textresults.where('error_msg IS NOT NULL')
      else
        @resource_import_textresults = @resource_import_textfile.resource_import_textresults
      end
    end
    @results_num = @resource_import_textresults.length
    @resource_import_textresults = @resource_import_textresults.page(params[:page]) unless params[:format] == 'tsv'

    if params[:format] == 'tsv'
      respond_to do |format|
        format.tsv { send_data ResourceImportTextresult.get_resource_import_textresults_tsv(@resource_import_textresults), :filename => Setting.resource_import_textresults_print_tsv.filename}
      end
    end
  end
end
