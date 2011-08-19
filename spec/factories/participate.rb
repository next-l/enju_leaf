FactoryGirl.define do
  factory :participate do |f|
    f.event{FactoryGirl.create(:event)}
    f.patron{FactoryGirl.create(:patron)}
  end
end
