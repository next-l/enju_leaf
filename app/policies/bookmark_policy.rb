class BookmarkPolicy < ApplicationPolicy
  def index?
    user.try(:has_role?, 'User')
  end

  def show?
    case user.try(:role).try(:name)
    when 'Administrator'
      true
    when 'Librarian'
      true
    when 'User'
      if record.user == user
        true
      elsif user.profile.try(:share_bookmarks)
        true
      else
        false
      end
    end
  end

  def create?
    user.try(:has_role?, 'User')
  end

  def update?
    case user.try(:role).try(:name)
    when 'Administrator'
      true
    when 'Librarian'
      true
    when 'User'
      true if record.user == user
    end
  end

  def destroy?
    update?
  end
end
