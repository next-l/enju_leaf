module BookmarkUrl
  def my_host?
    url = URI.parse(self)
    config_url = URI.parse(LibraryGroup.site_config.url)
    if url.host == config_url.host and url.port == config_url.port
      true
    else
      false
    end
  end

  def bookmarkable?
    if self.my_host?
      url = URI.parse(self)
      unless url.path.split("/").reverse[1] == "manifestations"
        return false
      end
    end
    true
  end

  def bookmarkable_id
    if self.my_host?
      path = URI.parse(self).path.split("/").reverse
      unless path[1] == "manifestations"
        nil
      else
        path[0]
      end
    end
  end
end

class String
  include BookmarkUrl
end
