class BookmarkSweeper < ActionController::Caching::Sweeper
  include ExpireEditableFragment
  observe Bookmark

  def after_save(record)
    expire_editable_fragment(record.manifestation, ['show_list', 'detail'])
    expire_tag_cloud(record)
  end

  def after_destroy(record)
    after_save(record)
  end
end
