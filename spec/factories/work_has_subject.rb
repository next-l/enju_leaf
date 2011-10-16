FactoryGirl.define do
  factory :work_has_subject do |f|
    f.work{FactoryGirl.create(:manifestation)}
    f.subject{FactoryGirl.create(:subject)}
  end
end
