class IdentifierTypePolicy < ApplicationPolicy
  def index?
    true if user.try(:has_role?, "Librarian")
  end

  def show?
    true if user.try(:has_role?, "Librarian")
  end

  def create?
    true if user.try(:has_role?, "Administrator")
  end

  def update?
    true if user.try(:has_role?, "Administrator")
  end

  def destroy?
    if user.try(:has_role?, "Administrator")
      true unless record.identifiers.exists?
    end
  end
end
