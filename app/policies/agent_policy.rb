class AgentPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    case user.try(:role).try(:name)
    when 'Administrator'
      true
    when 'Librarian'
      true if record.required_role_id <= 3
    when 'User'
      true if record.required_role_id <= 2
    else
      true if record.required_role_id <= 1
    end
  end

  def create?
    true if user.try(:has_role?, 'Librarian')
  end

  def update?
    true if user.try(:has_role?, 'Librarian')
  end

  def destroy?
    true if user.try(:has_role?, 'Librarian')
  end
end
