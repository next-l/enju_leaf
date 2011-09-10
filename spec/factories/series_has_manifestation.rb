FactoryGirl.define do
  factory :series_has_manifestation do |f|
    f.manifestation{FactoryGirl.create(:manifestation)}
    f.series_statement{FactoryGirl.create(:series_statement)}
  end
end
