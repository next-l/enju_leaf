class SubjectTypePolicy < ApplicationPolicy
  def index?
    true if user.try(:has_role?, 'Librarian')
  end

  def show?
    true if user.try(:has_role?, 'Librarian')
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
