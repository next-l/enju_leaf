module EventCategoriesHelper
  def select_checkin_date
    [[t('activerecord.attributes.event_category.checkin_ng_post'), 1], [t('activerecord.attributes.event_category.checkin_ng_pre'), 2]]
  end
end

