class PageSweeper < ActionController::Caching::Sweeper
  include ExpireEditableFragment
  observe Create, Realize, Produce, Own, Exemplify, Patron,
    SeriesStatement, SeriesHasManifestation, PictureFile, Shelf, Library

  def after_save(record)
    case
    when record.is_a?(Library)
      #expire_fragment(:controller => :libraries, :action => :index, :page => 'menu')
      expire_menu
    when record.is_a?(Shelf)
      # TODO: 書架情報が更新されたときのキャッシュはバッチで削除する
      #record.items.each do |item|
      #  expire_editable_fragment(item, ['holding'])
      #end
    when record.is_a?(Create)
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.work)
    when record.is_a?(Realize)
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.expression)
    when record.is_a?(Produce)
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.manifestation)
    when record.is_a?(Own)
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.item)
      expire_editable_fragment(record.item.manifestation)
    when record.is_a?(Exemplify)
      expire_editable_fragment(record.manifestation, ['detail', 'show_list', 'holding'])
      expire_editable_fragment(record.item)
    when record.is_a?(SeriesStatement)
      record.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation, ['detail'])
      end
    when record.is_a?(SeriesHasManifestation)
      expire_editable_fragment(record.manifestation)
    when record.is_a?(PictureFile)
      if record.picture_attachable_type?
        case
        when record.picture_attachable.is_a?(Manifestation)
          expire_editable_fragment(record.picture_attachable, ['picture_file', 'book_jacket'])
        when record.picture_attachable.is_a?(Patron)
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
