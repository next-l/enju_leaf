FactoryGirl.define do
  factory :subject_has_classification do |f|
    f.classification_id{FactoryGirl.create(:classification).id}
    f.subject_id{FactoryGirl.create(:subject).id}
  end
end
