class AnswerPolicy < ApplicationPolicy
  def index?
    true
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
      elsif record.question.shared?
        true
      else
        false
      end
    else
      true if record.question.shared?
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
