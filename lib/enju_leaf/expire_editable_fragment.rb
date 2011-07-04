module ExpireEditableFragment
  def expire_editable_fragment(record, fragments = [], formats = [])
    fragments.uniq!
    fragments = ['detail'] if fragments.empty?
    if record
      if record.is_a?(Manifestation)
        expire_manifestation_cache(record, fragments, formats)
      else
        I18n.available_locales.each do |locale|
          Role.all_cache.each do |role|
            fragments.each do |fragment|
              expire_fragment(:controller => record.class.to_s.pluralize.downcase, :action => :show, :id => record.id, :page => fragment, :role => role.name, :locale => locale)
            end
          end
        end
      end
    end
  end

  def expire_manifestation_cache(manifestation, fragments = [], formats = [])
    fragments = %w[detail pickup book_jacket title picture_file show_list edit_list reserve_list show_index] if fragments.size == 1 and fragments.first == 'detail'
    expire_fragment(:controller => :manifestations, :action => :index, :page => 'numdocs')
    fragments.uniq.each do |fragment|
      expire_manifestation_fragment(manifestation, fragment, formats)
    end
    manifestation.bookmarks.each do |bookmark|
      expire_tag_cloud(bookmark)
    end
  end

  def expire_manifestation_fragment(manifestation, fragment, formats = [])
    formats = ['atom', 'csv', 'html', 'mods', 'mobile', 'oai_list_identifiers', 'oai_list_records', 'rdf', 'rss'] if formats.empty?
    if manifestation
      I18n.available_locales.each do |locale|
        Role.all_cache.each do |role|
          expire_fragment(:controller => :manifestations, :action => :show, :id => manifestation.id, :page => fragment, :role => role.name, :locale => locale, :manifestation_id => nil)
          formats.each do |format|
            expire_fragment(:controller => :manifestations, :action => :show, :id => manifestation.id, :page => fragment, :role => role.name, :locale => locale, :format => format, :manifestation_id => nil)
          end
        end
      end
    end
  end

  def expire_tag_cloud(bookmark)
    I18n.available_locales.each do |locale|
      Role.all_cache.each do |role|
        expire_fragment(:controller => :tags, :action => :index, :page => 'user_tag_cloud', :user_id => bookmark.user.username, :locale => locale, :role => role.name, :user_id => nil)
        expire_fragment(:controller => :tags, :action => :index, :page => 'public_tag_cloud', :locale => locale, :role => role.name, :user_id => nil)
      end
    end
  end

end
