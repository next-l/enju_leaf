module ExpireEditableFragment
  def expire_editable_fragment(record, fragments = [])
    fragments.uniq!
    if record.is_a?(Manifestation)
      if fragments.empty?
        fragments = %w[manifestation_html show_detail_user_html show_detail_librarian_html pickup_html title_html title_mobile index_sru list_identifiers_oai list_records_oai]
      end
      expire_manifestation_cache(record, fragments)
    else
      I18n.available_locales.each do |locale|
        Role.all_cache.each do |role|
          fragments.each do |fragment|
            expire_fragment(":#{record.class.to_s.downcase}" => record.id, :fragment => fragment, :role => role.name, :locale => locale)
          end
        end
      end
    end
  end

  private
  def expire_manifestation_cache(manifestation, fragments = [])
    I18n.available_locales.each do |locale|
      Role.all_cache.each do |role|
        fragments.uniq.each do |fragment|
          expire_fragment([:manifestation => manifestation.id, :fragment => fragment, :role => role.name, :locale => locale])
        end
      end
    end
  end
end
