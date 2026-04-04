FactoryBot.define do
  factory :subject do |f|
    f.sequence(:term) { |n| "subject_#{n}" }
    f.subject_heading_type_id { FactoryBot.create(:subject_heading_type).id }
    f.subject_type_id { FactoryBot.create(:subject_type).id }
  end
end
