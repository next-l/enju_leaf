class PageSweeper < ActionController::Caching::Sweeper
    include ExpireEditableFragment
    observe Create, Realize, Produce, Own, Patron, Language, Checkin,
    SeriesStatement, SubjectHeadingType, PictureFile, Shelf, Tag, Answer

  def after_save(record)
    case
    when record.is_a?(Role)
      expire_page_fragment
    when record.is_a?(Library)
      #expire_fragment(:controller => :libraries, :action => :index, :page => 'menu')
      expire_menu
      expire_page_fragment
    when record.is_a?(Shelf)
      # TODO: 書架情報が更新されたときのキャッシュはバッチで削除する
      #record.items.each do |item|
      #  expire_editable_fragment(item, ['holding'])
      #end
    when record.is_a?(Tag)
      record.taggings.collect(&:taggable).each do |taggable|
        expire_editable_fragment(taggable)
      end
    when record.is_a?(Subject)
      expire_editable_fragment(record)
      record.works.each do |work|
        expire_editable_fragment(work)
        work.manifestations.each do |manifestation|
          expire_editable_fragment(manifestation)
        end
      end
      record.classifications.each do |classification|
        expire_editable_fragment(classification)
      end
    when record.is_a?(Classification)
      expire_editable_fragment(record)
      record.subjects.each do |subject|
        expire_editable_fragment(subject)
      end
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
    when record.is_a?(Checkin)
      expire_editable_fragment(record.item, 'holding')
    when record.is_a?(Language)
      Rails.cache.fetch('language_all'){Language.all}.each do |language|
        expire_fragment(:page => 'header', :locale => language.iso_639_1)
        expire_fragment(:page => 'select_locale', :locale => language.iso_639_1)
        expire_fragment(:controller => 'page', :locale => language.iso_639_1)
      end
    when record.is_a?(SeriesStatement)
      record.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation, ['detail'])
      end
    when record.is_a?(SubjectHeadingTypeHasSubject)
      expire_editable_fragment(record.subject)
    when record.is_a?(PictureFile)
      case
      when record.picture_attachable.is_a?(Resource)
        expire_editable_fragment(record.picture_attachable, ['picture_file', 'book_jacket'])
      when record.picture_attachable.is_a?(Patron)
        expire_editable_fragment(record.picture_attachable, ['picture_file'])
      end
    when record.is_a?(Answer)
      record.items.each do |item|
        expire_editable_fragment(item.manifestation, ['detail'])
      end
    end
  end

  def after_destroy(record)
    after_save(record)
  end

  def expire_menu
    I18n.available_locales.each do |locale|
      Rails.cache.fetch('role_all'){Role.all}.each do |role|
        expire_fragment(:controller => :page, :page => 'menu', :role => role.name, :locale => locale.to_s)
      end
    end
  end
end
