class ReservePolicy < ApplicationPolicy
  def index?
    user.try(:has_role?, 'User')
  end

  def show?
    if user.try(:has_role?, 'Librarian')
      true
    elsif user && (user == record.user)
      true
    end
  end

  def create?
    if user.try(:has_role?, 'Librarian')
      true
    elsif user.try(:has_role?, 'User')
      true if user.profile.user_number.try(:present?)
    end
  end

  def update?
    if user.try(:has_role?, 'Librarian')
      true
    elsif user && (user == record.user)
      true
    end
  end

  def destroy?
    if user.try(:has_role?, 'Librarian')
      true
    elsif user && (user == record.user)
      true
    end
  end
end
