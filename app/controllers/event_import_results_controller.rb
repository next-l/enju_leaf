class EventImportResultsController < InheritedResources::Base
  respond_to :html, :xml, :csv
  before_filter :check_client_ip_address
  before_filter :access_denied, :except => [:index, :show]
  load_and_authorize_resource
  has_scope :file_id

  def index
    @event_import_file = EventImportFile.where(:id => params[:event_import_file_id]).first
    @event_import_results = @event_import_file.event_import_results if @event_import_file
    @results_num = @event_import_results.length
    @event_import_results = @event_import_results.page(params[:page]) unless params[:format] == 'tsv'

    if params[:format] == 'tsv'
      respond_to do |format|
        format.tsv { send_data EventImportResult.get_event_import_results_tsv(@event_import_results), :filename => configatron.event_import_results_print_tsv.filename }
      end
    end
  end
end
