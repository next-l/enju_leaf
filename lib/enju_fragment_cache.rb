module EnjuFragmentCache
  def generate_fragment_cache
    url = "#{LibraryGroup.url}#{self.class.name.underscore.pluralize}/#{id}"
    Net::HTTP.get(URI.parse(url))
  end
end
