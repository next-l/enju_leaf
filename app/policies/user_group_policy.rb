class UserGroupPolicy < AdminPolicy
  def index?
    true
  end

  def create?
    user.try(:has_role?, 'Administrator')
  end

  def destroy?
    if user.try(:has_role?, 'Administrator')
      record.users.empty?
    end
  end
end
