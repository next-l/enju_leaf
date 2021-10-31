class MessagePolicy < ApplicationPolicy
  def index?
    true if user.try(:has_role?, 'User')
  end

  def show?
    case user.try(:role).try(:name)
    when 'Administrator'
      true
    when 'Librarian'
      true if record.try(:receiver) == user
    when 'User'
      true if record.try(:receiver) == user
    end
  end

  def create?
    true if user.try(:has_role?, 'Librarian')
  end

  def update?
    case user.try(:role).try(:name)
    when 'Administrator'
      true if record.try(:receiver) == user
    when 'Librarian'
      true if record.try(:receiver) == user
    end
  end

  def destroy?
    show?
  end

  def destroy_selected?
    true if user.try(:has_role?, 'User')
  end
end
