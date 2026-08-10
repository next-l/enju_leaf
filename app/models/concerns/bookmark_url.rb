module BookmarkUrl
  def my_host?
    url = ::Addressable::URI.parse(self)
    raise ::Addressable::URI::InvalidURIError unless url.host

    config_url = ::Addressable::URI.parse(LibraryGroup.site_config.url)
    return true if url.host == config_url.host && url.port == config_url.port && [ "http", "https" ].include?(url.scheme)

    false
  end

  def bookmarkable?
    return true unless self.my_host?

    path = ::Addressable::URI.parse(self).path.split("/").reverse
    return true if path[1] == "manifestations" and Manifestation.find_by(id: path[0])

    false
  rescue ::Addressable::URI::InvalidURIError
    false
  end

  def bookmarkable_id
    return unless self.my_host?

    path = ::Addressable::URI.parse(self).path.split("/").reverse
    return true if path[0] && path[1] == "manifestations"

    false
  end
end

class String
  include BookmarkUrl
end
