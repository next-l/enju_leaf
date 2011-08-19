FactoryGirl.define do
  factory :subject_heading_type_has_subject do |f|
    f.subject_heading_type{FactoryGirl.create(:subject_heading_type)}
    f.subject{FactoryGirl.create(:subject)}
  end
end
