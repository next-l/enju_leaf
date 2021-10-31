class RequestTypePolicy < ApplicationPolicy
  def index?
    true if user.try(:has_role?, 'Librarian')
  end

  def show?
    true if user.try(:has_role?, 'Librarian')
  end

  def create?
    false
  end

  def update?
    true if user.try(:has_role?, 'Administrator')
  end

  def destroy?
    false
  end
end
