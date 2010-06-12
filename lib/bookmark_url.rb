module BookmarkUrl
  def my_host?
    url = URI.parse(self)
    config_url = URI.parse(LibraryGroup.url)
    if url.host == config_url.host and url.port == config_url.port
      true
    else
      false
    end
  end

  def bookmarkable?
    if self.my_host?
      url = URI.parse(self)
      unless url.path.split("/").reverse[1] == "resources"
        return false
      end
    end
    true
  end
end

class String
  include BookmarkUrl
end
