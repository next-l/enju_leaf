module EnjuLeaf
  class Ability
    include CanCan::Ability
  
    def initialize(user, ip_address = nil)

      case user.try(:role).try(:name)
      when 'Administrator'
        can :manage, [
          UserExportFile,
          UserImportFile
        ] if LibraryGroup.site_config.network_access_allowed?(ip_address)
        can :read, [
          UserImportResult
        ] if LibraryGroup.site_config.network_access_allowed?(ip_address)
      when 'Librarian'
        can :manage, [
          UserImportFile
        ] if LibraryGroup.site_config.network_access_allowed?(ip_address)
        can :read, [
          UserImportResult
        ] if LibraryGroup.site_config.network_access_allowed?(ip_address)
      when 'User'
      else
      end
    end
  end
end
