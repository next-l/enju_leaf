class UserHasRolesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def index
    @user_has_roles = @user_has_roles.page(params[:page])
  end
end
