class UserHasRolesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @user_has_role = UserHasRole.find(params[:id])
    if params[:position]
      @user_has_role.insert_at(params[:position])
      redirect_to user_has_roles_url
      return
    end
    update!
  end

  protected
  def collection
    @user_has_roles ||= end_of_association_chain.paginate(:page => params[:page])
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.user_has_role')}
  end
end
