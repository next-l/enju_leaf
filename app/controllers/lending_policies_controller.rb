class LendingPoliciesController < InheritedResources::Base
  load_and_authorize_resource
  before_filter :get_user_group, :get_item
  before_filter :prepare_options, :only => [:new, :edit]

  def index
    @lending_policies = @lending_policies.page(params[:page])
  end

  private
  def prepare_options
    @user_groups = UserGroup.order(:position)
  end
end
