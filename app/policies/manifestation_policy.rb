class ManifestationPolicy < ApplicationPolicy
  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      role_id = user&.role&.id || 1
      scope.where("manifestations.required_role_id <= ?", role_id)
    end

    private

    attr_reader :user, :scope
  end

  def index?
    true
  end

  def show?
    if user&.role
      case user.role.name
      when "Administrator"
        return true
      when "Librarian"
        return true if record.required_role_id <= 3
      when "User"
        return true if record.required_role_id <= 2
      end
    end

    true if record.required_role_id <= 1
  end

  def create?
    true if user.try(:has_role?, "Librarian")
  end

  def edit?
    return false unless user&.role

    case user.role.name
    when "Administrator"
      true
    when "Librarian"
      true if record.required_role_id <= 3
    when "User"
      true if record.required_role_id <= 2
    end
  end

  def update?
    true if user.try(:has_role?, "Librarian")
  end

  def destroy?
    return false if record.items.exists?
    return false if record.try(:is_reserved?)
    return false unless user&.role

    if record.series_master?
      return false if record.children.exists?
    end

    case user.role.name
    when "Administrator"
      true
    when "Librarian"
      true if record.required_role_id <= 3
    else
      false
    end
  end
end
