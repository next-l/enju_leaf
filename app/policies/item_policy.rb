class ItemPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true if user.try(:has_role?, 'Librarian')
  end

  def edit?
    true if user.try(:has_role?, 'Librarian')
  end

  def update?
    true if user.try(:has_role?, 'Librarian')
  end

  def destroy?
    if user.try(:has_role?, 'Librarian')
      record.removable?
    end
  end
end
