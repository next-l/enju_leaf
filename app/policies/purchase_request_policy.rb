class PurchaseRequestPolicy < ApplicationPolicy
  def index?
    true if user.try(:has_role?, 'User')
  end

  def show?
    if user.try(:has_role?, 'Librarian')
      true
    elsif user.try(:has_role?, 'User')
      true if record.user == user
    end
  end

  def create?
    true if user.try(:has_role?, 'User')
  end

  def update?
    show?
  end

  def destroy?
    show?
  end
end
