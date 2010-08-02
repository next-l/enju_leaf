class BookmarkSweeper < ActionController::Caching::Sweeper
  include ExpireEditableFragment
  observe Bookmark

  def after_save(record)
    # Not supported by Memcache
    # expire_fragment(%r{manifestations/\d*})
    expire_editable_fragment(record.manifestation)
    expire_tag_cloud(record)
  end

  def after_destroy(record)
    after_save(record)
  end
end
