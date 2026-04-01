FactoryBot.define do
  factory :subject do |f|
    f.sequence(:term) {|n| "subject_#{n}"}
    f.subject_heading_type_id {FactoryBot.create(:subject_heading_type).id}
    f.subject_type_id {FactoryBot.create(:subject_type).id}
  end
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
