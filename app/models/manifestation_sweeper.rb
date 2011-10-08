class ManifestationSweeper < ActionController::Caching::Sweeper
  include ExpireEditableFragment
  observe Manifestation

  def after_save(record)
    expire_editable_fragment(record)
    record.items.each do |item|
      expire_editable_fragment(item)
    end
    record.creators.each do |creator|
      expire_editable_fragment(creator)
    end
    record.contributors.each do |contributor|
      expire_editable_fragment(contributor)
    end
    record.publishers.each do |publisher|
      expire_editable_fragment(publisher)
    end
  end

  def after_destroy(record)
    after_save(record)
  end
end
