module LocSearchHelper
  def link_to_import_from_loc(lccn)
    if lccn.blank?
      t('enju_loc.not_available')
    else
      manifestation = LccnRecord.find_by(body: lccn)&.manifestation
      unless manifestation
        button_to t('enju_loc.add'), loc_search_index_path(book: {lccn: lccn}), method: :post, data: {disable_with: t('page.saving')}
      else
        link_to t('enju_loc.already_exists'), manifestation
      end
    end
  end
end
