class ResourceImportResultsController < InheritedResources::Base
  #respond_to :html, :xml
  before_filter :access_denied, :except => [:index, :show]
  before_filter :check_client_ip_address
  load_and_authorize_resource
end
