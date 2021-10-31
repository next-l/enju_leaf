class PictureFilePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    case user.try(:role).try(:name)
    when 'Librarian'
      true
    when 'User'
      true if record.picture_attachable.try(:required_role_id).to_i <= 2
    else
      true if record.picture_attachable.try(:required_role_id).to_i <= 1
    end
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
    true if user.try(:has_role?, 'Librarian')
  end
end
