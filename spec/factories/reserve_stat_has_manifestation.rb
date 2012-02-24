FactoryGirl.define do
  factory :reserve_stat_has_manifestation do |f|
    f.manifestation_reserve_stat_id{FactoryGirl.create(:manifestation_reserve_stat).id}
    f.manifestation_id{FactoryGirl.create(:manifestation).id}
  end
end
