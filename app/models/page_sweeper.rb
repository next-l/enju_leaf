class PageSweeper < ActionController::Caching::Sweeper
  include ExpireEditableFragment
  observe Create, Realize, Produce, Own, Exemplify, Patron,
    SeriesStatement, SeriesHasManifestation, PictureFile, Shelf, Library

  def after_save(record)
    case record.class
    when Library
      #expire_fragment(:controller => :libraries, :action => :index, :page => 'menu')
      expire_menu
    when Shelf
      # TODO: 書架情報が更新されたときのキャッシュはバッチで削除する
      #record.items.each do |item|
      #  expire_editable_fragment(item, ['holding'])
      #end
    when Create
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.work)
    when Realize
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.expression)
    when Produce
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.manifestation)
    when Own
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.item)
      expire_editable_fragment(record.item.manifestation)
    when Exemplify
      expire_editable_fragment(record.manifestation, ['detail', 'show_list', 'holding'])
      expire_editable_fragment(record.item)
    when record.is_a?(SeriesStatement)
      record.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation, ['detail'])
      end
    when SeriesHasManifestation
      expire_editable_fragment(record.manifestation)
    when PictureFile
      if record.picture_attachable_type?
        case record.picture_attachable.class
        when Manifestation
          expire_editable_fragment(record.picture_attachable, ['picture_file', 'book_jacket'])
        when Patron
          expire_editable_fragment(record.picture_attachable, ['picture_file'])
        end
      end
    end
  end

  def after_destroy(record)
    after_save(record)
  end

  def expire_menu
    I18n.available_locales.each do |locale|
      Role.all_cache.each do |role|
        expire_fragment(:controller => :page, :page => 'menu', :role => role.name, :locale => locale)
      end
    end
  end
end
