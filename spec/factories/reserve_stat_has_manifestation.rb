FactoryGirl.define do
  factory :reserve_stat_has_manifestation do |f|
    f.manifestation_reserve_stat{FactoryGirl.create(:manifestation_reserve_stat)}
    f.manifestation{FactoryGirl.create(:manifestation)}
  end
end
