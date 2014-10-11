class ProfilePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def index?
    user.try(:has_role?, 'Librarian')
  end

  def show?
    if user.try(:has_role?, 'User')
      true
    end
  end

  def create?
    user.try(:has_role?, 'Librarian')
  end

  def update?
    if user.try(:has_role?, 'Librarian')
      true
    else
      true if user == record
    end
  end

  def destroy?
    false
  end
end
