FactoryBot.define do
  factory :series_statement do
    sequence(:original_title) { |n| "series_statement_#{n}" }
    sequence(:creator_string) { |n| "シリーズの著者 #{n}" }
  end

  factory :series_statement_serial, class: SeriesStatement do
    sequence(:original_title) { |n| "series_statement_serial_#{n}" }
    # f.root_manifestation_id{FactoryBot.create(:manifestation_serial).id}
    series_master { true }
  end
end
