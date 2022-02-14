module LocSearchHelper
  def link_to_import_from_loc(lccn)
    if lccn.blank?
      t('enju_loc.not_available')
    else
      identifier_type = IdentifierType.find_by(name: 'lccn')
      if identifier_type
        manifestation = Identifier.find_by(body: lccn, identifier_type_id: identifier_type.id)&.manifestation
      end
      unless manifestation
        button_to t('enju_loc.add'), loc_search_index_path(book: {lccn: lccn}), method: :post, data: {disable_with: t('page.saving')}
      else
        link_to t('enju_loc.already_exists'), manifestation
      end
    end
  end
end
