FactoryGirl.define do
  factory :checkout_stat_has_manifestation do |f|
    f.manifestation_checkout_stat_id{FactoryGirl.create(:manifestation_checkout_stat).id}
    f.manifestation_id{FactoryGirl.create(:manifestation).id}
  end
end
