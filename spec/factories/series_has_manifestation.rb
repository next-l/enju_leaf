FactoryBot.define do
  factory :series_has_manifestation do |f|
    f.manifestation_id{FactoryBot.create(:manifestation).id}
    f.series_statement_id{FactoryBot.create(:series_statement).id}
  end
end
