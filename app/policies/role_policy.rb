class RolePolicy < ApplicationPolicy
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
    if user.try(:has_role?, 'Librarian')
      true
    elsif user.try(:has_role?, 'User')
      true if record == user.profile
    end
  end

  def destroy?
    false
  end
end
