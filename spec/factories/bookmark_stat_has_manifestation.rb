FactoryGirl.define do
  factory :bookmark_stat_has_manifestation do |f|
    f.bookmark_stat{FactoryGirl.create(:bookmark_stat)}
    f.manifestation{FactoryGirl.create(:manifestation)}
  end
end
