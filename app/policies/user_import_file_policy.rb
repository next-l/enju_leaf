class UserImportFilePolicy < AdminPolicy
  def create?
    user.try(:has_role?, 'Librarian')
  end

  def update?
    user.try(:has_role?, 'Librarian')
  end

  def destroy?
    user.try(:has_role?, 'Librarian')
  end
end
