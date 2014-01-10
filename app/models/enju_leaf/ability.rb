module EnjuLeaf
  class Ability
    include CanCan::Ability
  
    def initialize(user, ip_address = nil)
  
      case user.try(:role).try(:name)
      when 'Administrator'
        can :index, User
        can [:read, :create, :update], User
        can :destroy, User do |u|
          if u != user and u.id != 1
            if defined?(EnjuCirculation)
               true if u.checkouts.not_returned.empty?
            else
              true
            end
          end
        end
        can [:read, :create, :update], UserGroup
        can :destroy, UserGroup do |user_group|
          user_group.users.empty?
        end
        can :manage, [
          UserHasRole
        ]
        can :manage, [
          UserImportFile
        ] if LibraryGroup.site_config.network_access_allowed?(ip_address)
        can :update, [
          Role
        ] if LibraryGroup.site_config.network_access_allowed?(ip_address)
        can :read, [
          Role,
          UserImportResult
        ] if LibraryGroup.site_config.network_access_allowed?(ip_address)
      when 'Librarian'
        can [:read, :create, :update], User
        can :destroy, User do |u|
          if u.role.name == 'User' and u != user
            if defined?(EnjuCirculation)
               true if u.checkouts.not_returned.empty?
            else
              true
            end
          end
        end
        can :manage, [
          UserImportFile
        ] if LibraryGroup.site_config.network_access_allowed?(ip_address)
        can :read, [
          Role,
          UserGroup
        ]
        can :read, [
          UserImportResult
        ] if LibraryGroup.site_config.network_access_allowed?(ip_address)
      when 'User'
        can :show, User
        can :update, User do |u|
          u == user
        end
        can :read, [
          UserGroup
        ]
      else
        can :read, [
          UserGroup
        ]
      end
    end
  end
end
