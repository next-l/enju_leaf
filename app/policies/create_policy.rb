class CreatePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true if user.try(:has_role?, 'Librarian')
  end

  def update?
    true if user.try(:has_role?, 'Librarian')
  end

  def destroy?
    true if user.try(:has_role?, 'Librarian')
  end
end
