class BasketSweeper < ActionController::Caching::Sweeper
  observe Basket

  def after_save(record)
    record.items.each do |item|
      expire_editable_fragment(item, ['holding'])
      I18n.available_locales.each do |locale|
        Rails.cache.fetch('role_all'){Role.all}.each do |role|
          [nil, 'html'].each do |page|
            expire_fragment(:controller => :resources, :action => :show, :id => item.manifestation.id, :locale => locale.to_s, :role => role.name, :page => 'detail', :user_id => nil)
          end
          expire_fragment(:controller => :resources, :action => :show, :id => item.manifestation.id, :page => 'detail', :locale => locale.to_s, :role => role.name, :user_id => nil)
        end
      end
    end
  end

  def after_destroy(record)
    after_save(record)
  end

  def expire_editable_fragment(record, fragments = nil)
    I18n.available_locales.each do |locale|
      Rails.cache.fetch('role_all'){Role.all}.each do |role|
        expire_fragment(:controller => record.class.to_s.pluralize.downcase, :action => :show, :id => record.id, :role => role.name, :locale => locale.to_s)
        if fragments
          fragments.each do |fragment|
            expire_fragment(:controller => record.class.to_s.pluralize.downcase, :action => :show, :id => record.id, :page => fragment, :role => role.name, :locale => locale.to_s)
          end
        end
      end
    end
  end

end
