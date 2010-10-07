class EventImportResultsController < InheritedResources::Base
  respond_to :html, :xml, :csv
  before_filter :check_client_ip_address
  before_filter :access_denied, :except => [:index, :show]
  load_and_authorize_resource
  has_scope :file_id

  def index
    @event_import_results = @event_import_results.paginate(:page => params[:page])
  end
end
