module CiniiBooksHelper
  def link_to_import_from_cinii(ncid)
    if ncid.blank?
      t('enju_nii.not_available')
    else
      identifier_type = IdentifierType.find_by(name: 'ncid')
      if identifier_type
        manifestation = Identifier.find_by(body: ncid, identifier_type_id: identifier_type.id)&.manifestation
      end
      unless manifestation
        button_to t('enju_nii.add'), cinii_books_path(book: {ncid: ncid}), method: :post, data: {disable_with: t('page.saving')}
      else
        link_to t('enju_nii.already_exists'), manifestation
      end
    end
  end
end
