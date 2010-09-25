class EventImportResultsController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  before_filter :access_denied, :except => [:index, :show]
  load_and_authorize_resource
end
