class UserExportFilePolicy < ApplicationPolicy
  def index?
    true if user.try(:has_role?, 'Administrator')
  end

  def show?
    true if user.try(:has_role?, 'Administrator')
  end

  def create?
    true if user.try(:has_role?, 'Administrator')
  end

  def update?
    true if user.try(:has_role?, 'Administrator')
  end

  def destroy?
    true if user.try(:has_role?, 'Administrator')
  end
end
