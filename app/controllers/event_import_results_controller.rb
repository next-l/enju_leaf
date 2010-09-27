class EventImportResultsController < InheritedResources::Base
  respond_to :html, :xml, :csv
  before_filter :check_client_ip_address
  before_filter :access_denied, :except => [:index, :show]
  load_and_authorize_resource
  has_scope :file_id

  protected
  def collection
    @event_import_results ||= end_of_association_chain.paginate(:page => params[:page])
  end
end
