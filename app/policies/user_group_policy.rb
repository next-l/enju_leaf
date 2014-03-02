class UserGroupPolicy < AdminPolicy
  def create?
    user.try(:has_role?, 'Administrator')
  end

  def destroy?
    if user.try(:has_role?, 'Administrator')
      record.users.empty?
    end
  end
end
