class ProfilePolicy < ApplicationPolicy
  def index?
    true if user.try(:has_role?, 'Librarian')
  end

  def show?
    case user.role.try(:name)
    when 'Administrator'
      true
    when 'Librarian'
      return true if record == user.profile
      true if %w(Librarian User Guest).include?(record.required_role.name)
    when 'User'
      return true if record == user.profile
      true if %w(User Guest).include?(record.required_role.name)
    end
  end

  def create?
    true if user.try(:has_role?, 'Librarian')
  end

  def update?
    case user.try(:role).try(:name)
    when 'Administrator'
      true
    when 'Librarian'
      unless record.user.try(:has_role?, 'Administrator')
        true if %w(User Guest Librarian).include?(record.required_role.name)
      end
    when 'User'
      return true if record == user.profile
    end
  end

  def destroy?
    return false unless user
    return false unless user.try(:has_role?, 'Librarian')
    if record.user
      if record != user.profile && record.user.id != 1
        if defined?(EnjuCirculation)
          if record.user.checkouts.not_returned.empty?
            true if record.user.deletable_by?(user)
          end
        else
          true if record.user.deletable_by?(user)
        end
      else
        false
      end
    else
      true
    end
  end
end
