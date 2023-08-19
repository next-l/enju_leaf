module NdlBooksHelper
  def link_to_import_from_ndl(iss_itemno)
    if iss_itemno.blank?
      t('enju_ndl.not_available')
    else
      ndl_bib_id_record = NdlBibIdRecord.find_by(body: iss_itemno)
      if ndl_bib_id_record
        link_to t('enju_ndl.already_exists'), ndl_bib_id_record.manifestation
      else
        button_to t('enju_ndl.add'), ndl_books_path(book: {iss_itemno: iss_itemno}), method: :post, data: {disable_with: t('page.saving')}
      end
    end
  end
end
