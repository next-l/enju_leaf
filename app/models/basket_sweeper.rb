class BasketSweeper < ActionController::Caching::Sweeper
  observe Basket
  include ExpireEditableFragment

  def after_save(record)
    record.items.each do |item|
      expire_editable_fragment(item, ['holding'])
      I18n.available_locales.each do |locale|
        Role.all_cache.each do |role|
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

end
