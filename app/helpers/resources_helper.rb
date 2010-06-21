module ResourcesHelper
  include ManifestationsHelper

  def resource_title(resource, action)
    string = 'Enju Light - '
    unless action == 'index'
      string << resource.original_title
    end
  end
end
