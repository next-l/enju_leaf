FactoryGirl.define do
  factory :subject_heading_type_has_subject do |f|
    f.subject_heading_type_id{FactoryGirl.create(:subject_heading_type).id}
    f.subject_id{FactoryGirl.create(:subject).id}
  end
end
