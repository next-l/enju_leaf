FactoryGirl.define do
  factory :checkout_stat_has_manifestation do |f|
    f.manifestation_checkout_stat{FactoryGirl.create(:manifestation_checkout_stat)}
    f.manifestation{FactoryGirl.create(:manifestation)}
  end
end
