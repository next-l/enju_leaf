class UserPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def index?
    user.try(:has_role?, 'Librarian')
  end

  def show?
    if user.try(:has_role?, 'User')
      true
    end
  end

  def create?
    user.try(:has_role?, 'Librarian')
  end

  def update?
    if user.try(:has_role?, 'Librarian')
      true
    else
      true if user == record
    end
  end

  def destroy?
    if user.try(:has_role?, 'Administrator')
      if user != record and record.id != 1
        if defined?(EnjuCirculation)
          true if record.checkouts.not_returned.empty?
        else
          true
        end
      end
    elsif user.try(:has_role?, 'Librarian')
      if record.role.name == 'User' and user != record
        if defined?(EnjuCirculation)
          true if record.checkouts.not_returned.empty?
        else
          true
        end
      end
    end
  end
end
