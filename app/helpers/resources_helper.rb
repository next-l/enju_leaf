module ResourcesHelper
  include ManifestationsHelper

  def resource_title(resource, action)
    string = LibraryGroup.site_config.display_name.localize
    unless action == 'index'
      string << ' - ' + resource.original_title.to_s
    end
    string << ' - Enju Light'
    string.html_safe
  end
end
