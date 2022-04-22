require 'localized_name'
require 'bookmark_url'

class String
  include LocalizedName
  include BookmarkUrl
end

