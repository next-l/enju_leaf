FactoryBot.define do
  factory :subject do |f|
    f.sequence(:term){|n| "subject_#{n}"}
    f.subject_heading_type_id{FactoryBot.create(:subject_heading_type).id}
    f.subject_type_id{FactoryBot.create(:subject_type).id}
  end
end

# == Schema Information
#
# Table name: subjects
#
#  id                      :bigint           not null, primary key
#  parent_id               :bigint
#  use_term_id             :bigint
#  term                    :string
#  term_transcription      :text
#  subject_type_id         :bigint           not null
#  scope_note              :text
#  note                    :text
#  required_role_id        :bigint           default(1), not null
#  lock_version            :integer          default(0), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  url                     :string
#  manifestation_id        :bigint
#  subject_heading_type_id :bigint
#
