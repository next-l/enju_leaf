class MessageRequestPolicy < ApplicationPolicy
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
    true if user.try(:has_role?, 'Librarian')
  end

  def destroy?
    true if user.try(:has_role?, 'Librarian')
  end
end
