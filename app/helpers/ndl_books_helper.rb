module NdlBooksHelper
  def link_to_import_from_ndl(iss_itemno)
    if iss_itemno.blank?
      t('enju_ndl.not_available')
    else
      identifier_type = IdentifierType.find_by(name: 'iss_itemno')
      if identifier_type
        manifestation = Identifier.find_by(body: iss_itemno, identifier_type_id: identifier_type.id)&.manifestation
      end
      if manifestation
        link_to t('enju_ndl.already_exists'), manifestation
      else
        button_to t('enju_ndl.add'), ndl_books_path(book: {iss_itemno: iss_itemno}), method: :post, data: {disable_with: t('page.saving')}
      end
    end
  end
end
