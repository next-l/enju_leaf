class InventoryFilePolicy < ApplicationPolicy
  def index?
    user.try(:has_role?, 'Librarian')
  end

  def show?
    user.try(:has_role?, 'Librarian')
  end

  def create?
    user.try(:has_role?, 'Librarian')
  end

  def update?
    user.try(:has_role?, 'Librarian')
  end

  def destroy?
    user.try(:has_role?, 'Librarian')
  end
end
