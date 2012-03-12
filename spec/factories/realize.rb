FactoryGirl.define do
  factory :realize do |f|
    f.expression_id{FactoryGirl.create(:manifestation).id}
    f.patron_id{FactoryGirl.create(:patron).id}
  end
end
