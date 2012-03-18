class PageSweeper < ActionController::Caching::Sweeper
  include ExpireEditableFragment
  observe Create, Realize, Produce, Own, Exemplify, Patron,
    SeriesStatement, SeriesHasManifestation, PictureFile, Shelf, Library

  def after_save(record)
    case record.class.to_s.to_sym
    when :Library
      #expire_fragment(:controller => :libraries, :action => :index, :page => 'menu')
    when :Shelf
      # TODO: 書架情報が更新されたときのキャッシュはバッチで削除する
      #record.items.each do |item|
      #  expire_editable_fragment(item, ['holding'])
      #end
    when :Create
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.work)
    when :Realize
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.expression)
    when :Produce
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.manifestation)
    when :Own
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.item)
      expire_editable_fragment(record.item.manifestation)
    when :Exemplify
      expire_editable_fragment(record.manifestation)
      expire_editable_fragment(record.item)
    when :SeriesStatement
      record.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation)
      end
    when :SeriesHasManifestation
      expire_editable_fragment(record.manifestation)
    when :PictureFile
      if record.picture_attachable_type?
        expire_editable_fragment(record.picture_attachable)
      end
    end
  end

  def after_destroy(record)
    after_save(record)
  end
end
