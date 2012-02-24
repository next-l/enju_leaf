FactoryGirl.define do
  factory :work_has_subject do |f|
    f.work_id{FactoryGirl.create(:manifestation).id}
    f.subject_id{FactoryGirl.create(:subject).id}
  end
end
