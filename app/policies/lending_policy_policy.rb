class LendingPolicyPolicy < ApplicationPolicy
  def index?
    user.try(:has_role?, 'Librarian')
  end

  def show?
    user.try(:has_role?, 'Librarian')
  end

  def create?
    false
  end

  def update?
    user.try(:has_role?, 'Administrator')
  end

  def destroy?
    user.try(:has_role?, 'Administrator')
  end
end
