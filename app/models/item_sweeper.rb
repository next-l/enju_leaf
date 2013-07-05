class ItemSweeper < ActionController::Caching::Sweeper
  include ExpireEditableFragment
  observe Item

  def after_save(record)
    item = Item.find(record.id)
    manifestation = item.manifestation
    expire_editable_fragment(item)
    if manifestation
      expire_editable_fragment(item.manifestation, ['detail', 'show_list', 'holding'])
      expire_page(:controller => :manifestations, :action => :show, :id => item.manifestation.id, :page => 'show_list')
    end
    record.patrons.each do |patron|
      expire_editable_fragment(patron)
    end
    record.donors.each do |donor|
      expire_editable_fragment(donor)
    end
  end

  def after_destroy(record)
    after_save(record)
  end
end
