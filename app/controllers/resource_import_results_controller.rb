class ResourceImportResultsController < InheritedResources::Base
  add_breadcrumb "I18n.t('activerecord.models.resource_import_result')", 'resource_import_results_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.resource_import_result'))", 'new_resource_import_result_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.showing', :model => I18n.t('activerecord.models.resource_import_result'))", 'new_resource_import_result_path', :only => [:show]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.resource_import_result'))", 'edit_resource_import_result_path([:id])', :only => [:edit, :update]
  respond_to :html, :json, :csv
  before_filter :access_denied, :except => [:index, :show]
  before_filter :check_client_ip_address
  load_and_authorize_resource
  has_scope :file_id

  def index
    @resource_import_file = ResourceImportFile.where(:id => params[:resource_import_file_id]).first
    if @resource_import_file
      if params[:display_result] && params[:display_result] == "has_msg"
        @resource_import_results = @resource_import_file.resource_import_results.where("error_msg is not null")
      else
        @resource_import_results = @resource_import_file.resource_import_results 
      end
    end
    @results_num = @resource_import_results.length
    @resource_import_results = @resource_import_results.page(params[:page]) unless params[:format] == 'tsv'

    if params[:format] == 'tsv'
      respond_to do |format|
        format.tsv { send_data ResourceImportResult.get_resource_import_results_tsv(@resource_import_results), :filename => Setting.resource_import_results_print_tsv.filename }
      end
    end
  end
end
