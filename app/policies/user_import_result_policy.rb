class UserImportResultPolicy < AdminPolicy
  def index?
    user.try(:has_role?, 'Librarian')
  end

  def destroy?
    false
  end
end
