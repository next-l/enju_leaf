class PatronSweeper < ActionController::Caching::Sweeper
  include ExpireEditableFragment
  observe Patron

  def after_save(record)
    expire_editable_fragment(record)
    record.works.each do |work|
      expire_editable_fragment(work)
    end
    record.expressions.each do |expression|
      expire_editable_fragment(expression)
    end
    record.manifestations.each do |manifestation|
      expire_editable_fragment(manifestation)
    end
    record.donated_items.each do |item|
      expire_editable_fragment(item)
    end
    record.original_patrons.each do |patron|
      expire_editable_fragment(patron)
    end
    record.derived_patrons.each do |patron|
      expire_editable_fragment(patron)
    end
  end

  def after_destroy(record)
    after_save(record)
  end
end
