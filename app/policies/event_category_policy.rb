class EventCategoryPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.try(:has_role?, 'Administrator')
  end

  def update?
    user.try(:has_role?, 'Administrator')
  end

  def destroy?
    if user.try(:has_role?, 'Administrator')
      if record.events.empty?
        true if !['unknown', 'closed'].include?(record.name)
      end
    end
  end
end
