class Subject < ApplicationRecord
  belongs_to :manifestation, touch: true, optional: true
  belongs_to :subject_type
  belongs_to :subject_heading_type
  belongs_to :required_role, class_name: "Role"

  validates :term, presence: true

  searchable do
    text :term
    time :created_at
    integer :required_role_id
  end

  strip_attributes only: :term

  paginates_per 10
end
