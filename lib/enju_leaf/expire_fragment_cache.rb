class ExpireFragmentCache
  def self.expire_fragment_cache(record, fragments = [])
    if record.is_a?(Manifestation)
      if fragments.empty?
        fragments = %w[manifestation_html show_detail_user_html show_detail_librarian_html pickup_html title_html title_mobile index_sru]
      end
    end

    I18n.available_locales.each do |locale|
      Role.all_cache.each do |role|
        fragments.each do |fragment|
          Rails.cache.delete([":#{record.class.to_s.downcase}" => record.id, :fragment => fragment, :role => role.name, :locale => locale])
        end
      end
    end
  end
end
