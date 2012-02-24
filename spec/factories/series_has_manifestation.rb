FactoryGirl.define do
  factory :series_has_manifestation do |f|
    f.manifestation_id{FactoryGirl.create(:manifestation).id}
    f.series_statement_id{FactoryGirl.create(:series_statement).id}
  end
end
