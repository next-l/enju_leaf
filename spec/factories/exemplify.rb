FactoryGirl.define do
  factory :exemplify do |f|
    f.manifestation_id do
      FactoryGirl.create(:manifestation).id
    end
    f.item_id do
      FactoryGirl.create(:item, :manifestation => nil).id
    end
  end
end
