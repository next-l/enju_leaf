FactoryGirl.define do
  factory :subject_has_classification do |f|
    f.classification{FactoryGirl.create(:classification)}
    f.subject{FactoryGirl.create(:subject)}
  end
end
