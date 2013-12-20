class PatronImportResultsController < InheritedResources::Base
  add_breadcrumb "I18n.t('activerecord.models.patron_import_result')", 'patron_import_results_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.patron_import_result'))", 'new_patron_import_result_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.patron_import_result'))", 'edit_patron_import_result_path([:id])', :only => [:edit, :update]
  respond_to :html, :json, :csv
  before_filter :check_client_ip_address
  before_filter :access_denied, :except => [:index, :show]
  load_and_authorize_resource
  has_scope :file_id

  def index
    @patron_import_file = PatronImportFile.where(:id => params[:patron_import_file_id]).first
    @patron_import_results = @patron_import_file.patron_import_results if @patron_import_file
    @results_num = @patron_import_results.length
    @patron_import_results = @patron_import_results.page(params[:page]) unless params[:format] == 'tsv' || params[:format] == 'csv'

    if (params[:format] == 'tsv' || params[:format] == 'csv')
      respond_to do |format|
        if SystemConfiguration.get("set_output_format_type") == false
          format.csv { send_data PatronImportResult.get_patron_import_results_tsv(@patron_import_results), :filename => Setting.patron_import_results_print_csv.filename } 
        else
          format.tsv { send_data PatronImportResult.get_patron_import_results_tsv(@patron_import_results), :filename => Setting.patron_import_results_print_tsv.filename } 
        end
      end
    end
  end
end
