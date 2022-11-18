class Subject < ApplicationRecord
  belongs_to :manifestation, touch: true, optional: true
  belongs_to :subject_type
  belongs_to :subject_heading_type
  belongs_to :required_role, class_name: 'Role'

  validates :term, presence: true

  searchable do
    text :term
    time :created_at
    integer :required_role_id
  end

  strip_attributes only: :term

  paginates_per 10
end

# == Schema Information
#
# Table name: subjects
#
#  id                      :bigint           not null, primary key
#  parent_id               :integer
#  use_term_id             :integer
#  term                    :string
#  term_transcription      :text
#  subject_type_id         :integer          not null
#  scope_note              :text
#  note                    :text
#  required_role_id        :bigint           default(1), not null
#  lock_version            :integer          default(0), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  url                     :string
#  manifestation_id        :bigint
#  subject_heading_type_id :integer
#
