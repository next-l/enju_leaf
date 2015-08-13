module EnjuLeaf
  class Ability
    include CanCan::Ability
  
    def initialize(user, ip_address = nil)

      case user.try(:role).try(:name)
      when 'Administrator'
        can :index, Profile
        can [:read, :create, :update], [User, Profile]
        can :destroy, Profile do |profile|
          if profile.user
            if profile != user.profile && profile.user.id != 1
              if defined?(EnjuCirculation)
                if profile.user.checkouts.not_returned.empty?
                  true if profile.user.deletable_by?(user)
                end
              else
                true if profile.user.deletable_by?(user)
              end
            end
          else
            true
          end
        end
        can [:read, :create, :update], UserGroup
        can :destroy, UserGroup do |user_group|
          user_group.profiles.empty?
        end
        can :manage, [
          UserHasRole
        ]
        can :manage, [
          UserExportFile,
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
        can :create, Profile
        can :read, Profile do |profile|
          profile == user.profile or %w(Librarian User Guest).include?(profile.required_role.name)
        end
        can :update, Profile do |profile|
          if profile.try(:user).try(:has_role?, 'Librarian')
            false
          else
            true
          end
        end
        can :destroy, Profile do |profile|
          if profile.user
            if profile != user.profile && profile.user.id != 1
              if defined?(EnjuCirculation)
                 if profile.user.checkouts.not_returned.empty?
                   true if profile.user.deletable_by?(user)
                 end
              else
                true if profile.user.deletable_by?(user)
              end
            end
          else
            true
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
        can :show, Profile do |profile|
	  profile == user.profile or %w(User Guest).include?(profile.required_role.name)
        end
        can :update, Profile do |profile|
          profile == user.profile
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
