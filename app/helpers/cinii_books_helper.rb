module CiniiBooksHelper
  def link_to_import_from_cinii(ncid)
    if ncid.blank?
      t('enju_nii.not_available')
    else
      ncid_record = NcidRecord.find_by(body: 'ncid')
      if ncid_record
        link_to t('enju_nii.already_exists'), ncid_record.manifestation
      else
        button_to t('enju_nii.add'), cinii_books_path(book: {ncid: ncid}), method: :post, data: {disable_with: t('page.saving')}
      end
    end
  end
end
