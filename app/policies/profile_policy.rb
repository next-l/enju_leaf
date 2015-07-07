class ProfilePolicy < ApplicationPolicy
  def index?
    true if user.try(:has_role?, 'Librarian')
  end

  def show?
    if user.try(:has_role?, 'Librarian')
      true
    elsif user.try(:has_role?, 'User')
      true if record == user.profile
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
      if record.try(:user).try(:has_role?, 'Librarian')
        false
      else
        true
      end
    when 'User'
      true if record == user.profile
    end
  end

  def destroy?
    return false unless user
    if user.try(:has_role?, 'Librarian')
      if record.user
        if record != user.profile && record.user.id != 1
          if defined?(EnjuCirculation)
            if record.user.checkouts.not_returned.empty?
              true if record.user.deletable_by?(user)
            end
          else
            true if record.user.deletable_by?(user)
          end
        end
      else
        true
      end
    else
      false
    end
  end
end
