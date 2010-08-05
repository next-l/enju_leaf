module ResourcesHelper
  include ManifestationsHelper

  def resource_title(resource, action)
    string = LibraryGroup.site_config.display_name.localize.dup
    unless action == ('index' or 'new')
      if resource.try(:original_title)
        string << ' - ' + resource.original_title.to_s
      end
    end
    string << ' - Next-L Enju Leaf'
    string.html_safe
  end
end
