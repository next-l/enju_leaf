class MissionControlController < ActionController::Base
  before_action :authenticate_admin!

  private

  def authenticate_admin!
    authenticate_user!
    current_user.role.name == 'Administrator'
  end
end
