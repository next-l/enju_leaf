CSV.generate(col_sep: "\t", row_sep: "\r\n") do |csv|
  csv << %w(id state maniestation_id title creator publisher pub_date isbn item_identifier call_number user_number username library created_at expired_at)
  @reserves.each do |reserve|
    csv << [
      reserve.id,
      reserve.current_state,
      reserve.manifestation_id,
      reserve.manifestation.original_title,
      reserve.manifestation.creators.pluck(:full_name).join('//'),
      reserve.manifestation.publishers.pluck(:full_name).join('//'),
      reserve.manifestation.pub_date,
      reserve.manifestation.identifier_contents(:isbn).join('//'),
      reserve.item.try(:item_identifier),
      reserve.item.try(:call_number),
      reserve.user.profile.try(:user_number),
      reserve.user.try(:username),
      reserve.pickup_location.try(:name),
      reserve.created_at,
      reserve.updated_at
    ]
  end
end
