class LibraryPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true if user.try(:has_role?, 'Administrator')
  end

  def update?
    true if user.try(:has_role?, 'Administrator')
  end

  def destroy?
    if user.try(:has_role?, 'Administrator')
      if record.profiles.empty?
        true if record.shelves.empty? && !record.web?
      end
    end
  end
end
