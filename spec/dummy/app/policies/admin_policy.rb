class AdminPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def index?
    user.try(:has_role?, 'Librarian')
  end

  def show?
    user.try(:has_role?, 'Librarian')
  end

  def create?
    false
  end

  def update?
    user.try(:has_role?, 'Administrator')
  end

  def destroy?
    false
  end
end
