class LibraryGroupSweeper < ActionController::Caching::Sweeper
  observe LibraryGroup
  def after_save(record)
    I18n.available_locales.each do |locale|
      expire_fragment("library_group_header_#{locale}")
    end
  end

  def after_destroy(record)
    after_save(record)
  end
end
