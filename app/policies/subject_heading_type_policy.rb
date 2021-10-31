class SubjectHeadingTypePolicy < ApplicationPolicy
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
      true if record.subjects.empty?
    end
  end
end
