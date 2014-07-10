class UserExportFilePolicy < AdminPolicy
  def index?
    user.try(:has_role?, 'Administrator')
  end

  def show?
    user.try(:has_role?, 'Administrator')
  end

  def create?
    user.try(:has_role?, 'Administrator')
  end

  def update?
    user.try(:has_role?, 'Administrator')
  end

  def destroy?
    user.try(:has_role?, 'Administrator')
  end
end
