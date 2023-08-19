class PeriodicalPolicy < ApplicationPolicy
  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      role_id = user&.role&.id || 1
      scope.joins(:manifestation).where('manifestations.required_role_id <= ?', role_id)
    end

    private

    attr_reader :user, :scope
  end

  def index?
    true if user.try(:has_role?, 'Librarian')
  end

  def show?
    true if user.try(:has_role?, 'Librarian')
  end

  def create?
    true if user.try(:has_role?, 'Librarian')
  end

  def update?
    true if user.try(:has_role?, 'Librarian')
  end

  def destroy?
    if user.try(:has_role?, 'Librarian')
      true if record.manifestations.empty?
    end
  end
end
