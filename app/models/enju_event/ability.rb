module EnjuEvent
  class Ability
    include CanCan::Ability
  
    def initialize(user, ip_address = nil)
      case user.try(:role).try(:name)
      when 'Administrator'
        can [:read, :create], EventCategory
        can [:update, :destroy, :delete], EventCategory do |event_category|
          !['unknown', 'closed'].include?(event_category.name)
        end
        can :manage, [
          Event,
          EventImportFile,
          Participate
        ]
        can :read, EventImportResult
      when 'Librarian'
        can :manage, [
          Event,
          EventImportFile,
          Participate
        ]
        can :read, [
          EventCategory,
          EventImportResult
        ]
      when 'User'
        can :read, [
          Event,
          EventCategory
        ]
      else
        can :read, [
          Event,
          EventCategory
        ]
      end
    end
  end
end
