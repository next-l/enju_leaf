class ManifestationSweeper < ActionController::Caching::Sweeper
  include ExpireEditableFragment
  observe Manifestation

  def after_save(record)
    expire_editable_fragment(record)
    record.items.each do |item|
      expire_editable_fragment(item)
    end
    record.patrons.each do |patron|
      expire_editable_fragment(patron)
    end
    Rails.cache.write("manifestation_search_total", Manifestation.search.total)
  end

  def after_destroy(record)
    after_save(record)
  end

end
