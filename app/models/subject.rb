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

# ## Schema Information
#
# Table name: `subjects`
#
# ### Columns
#
# Name                           | Type               | Attributes
# ------------------------------ | ------------------ | ---------------------------
# **`id`**                       | `bigint`           | `not null, primary key`
# **`lock_version`**             | `integer`          | `default(0), not null`
# **`note`**                     | `text`             |
# **`scope_note`**               | `text`             |
# **`term`**                     | `string`           |
# **`term_transcription`**       | `text`             |
# **`url`**                      | `string`           |
# **`created_at`**               | `datetime`         | `not null`
# **`updated_at`**               | `datetime`         | `not null`
# **`manifestation_id`**         | `bigint`           |
# **`parent_id`**                | `bigint`           |
# **`required_role_id`**         | `bigint`           | `default(1), not null`
# **`subject_heading_type_id`**  | `bigint`           |
# **`subject_type_id`**          | `bigint`           | `not null`
# **`use_term_id`**              | `bigint`           |
#
# ### Indexes
#
# * `index_subjects_on_manifestation_id`:
#     * **`manifestation_id`**
# * `index_subjects_on_parent_id`:
#     * **`parent_id`**
# * `index_subjects_on_required_role_id`:
#     * **`required_role_id`**
# * `index_subjects_on_subject_type_id`:
#     * **`subject_type_id`**
# * `index_subjects_on_term`:
#     * **`term`**
# * `index_subjects_on_use_term_id`:
#     * **`use_term_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`required_role_id => roles.id`**
#
