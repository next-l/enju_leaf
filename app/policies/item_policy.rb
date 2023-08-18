class ItemPolicy < ApplicationPolicy
  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      role_id = user&.role&.id || 1
      scope.where('items.required_role_id <= ?', role_id)
    end

    private

    attr_reader :user, :scope
  end

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
