class LendingPoliciesController < InheritedResources::Base
  load_and_authorize_resource
  before_filter :get_user_group, :get_item
  before_filter :prepare_options, :only => [:new, :edit]

  def index
    @lending_policies = @lending_policies.paginate(:page => params[:page])
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.lending_policy')}
  end

  def prepare_options
    @user_groups = UserGroup.all(:order => :position)
  end
end
