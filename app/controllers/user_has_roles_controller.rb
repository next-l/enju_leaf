class UserHasRolesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def index
    @user_has_roles = @user_has_roles.paginate(:page => params[:page])
  end
end
