class LibraryGroupSweeper < ActionController::Caching::Sweeper
  observe LibraryGroup
  def after_save(record)
    I18n.available_locales.each do |locale|
      expire_fragment(:controller => 'library_groups', :id => record.id, :action_suffix => 'header', :locale => locale)
    end
  end

  def after_destroy(record)
    after_save(record)
  end
end
