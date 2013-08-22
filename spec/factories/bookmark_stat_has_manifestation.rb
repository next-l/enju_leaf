if defined?(BookmarkStatHasManifestation)

FactoryGirl.define do
  factory :bookmark_stat_has_manifestation do |f|
    f.bookmark_stat_id{FactoryGirl.create(:bookmark_stat).id}
    f.manifestation_id{FactoryGirl.create(:manifestation).id}
  end
end

end
