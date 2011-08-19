FactoryGirl.define do
  factory :exemplify do |f|
    f.manifestation {FactoryGirl.create(:manifestation)}
    f.item {FactoryGirl.create(:item)}
  end
end
