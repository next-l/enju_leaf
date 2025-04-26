FactoryBot.define do
  factory :manifestation do |f|
    f.sequence(:original_title) {|n| "manifestation_title_#{n}"}
    f.carrier_type_id {CarrierType.find(1).id}
  end

  factory :manifestation_serial, class: Manifestation do |f|
    f.sequence(:original_title) {|n| "manifestation_title_#{n}"}
    f.carrier_type_id {CarrierType.find(1).id}
    f.language_id {Language.find(1).id}
    f.serial {true}
    f.series_statements {[ FactoryBot.create(:series_statement_serial) ]}
  end
end

# == Schema Information
#
# Table name: manifestations
#
#  id                              :bigint           not null, primary key
#  abstract                        :text
#  access_address                  :string
#  attachment_content_type         :string
#  attachment_file_name            :string
#  attachment_file_size            :integer
#  attachment_updated_at           :datetime
#  available_at                    :datetime
#  classification_number           :string
#  date_accepted                   :datetime
#  date_captured                   :datetime
#  date_copyrighted                :datetime
#  date_of_publication             :datetime
#  date_submitted                  :datetime
#  depth                           :integer
#  description                     :text
#  dimensions                      :text
#  edition                         :integer
#  edition_string                  :string
#  end_page                        :integer
#  extent                          :text
#  fulltext                        :text
#  fulltext_content                :boolean
#  height                          :integer
#  issue_number                    :integer
#  issue_number_string             :string
#  lock_version                    :integer          default(0), not null
#  manifestation_identifier        :string
#  memo                            :text
#  month_of_publication            :integer
#  note                            :text
#  original_title                  :text             not null
#  price                           :integer
#  pub_date                        :string
#  publication_place               :text
#  repository_content              :boolean          default(FALSE), not null
#  required_score                  :integer          default(0), not null
#  serial                          :boolean
#  serial_number                   :integer
#  serial_number_string            :string
#  start_page                      :integer
#  statement_of_responsibility     :text
#  subscription_master             :boolean          default(FALSE), not null
#  title_alternative               :text
#  title_alternative_transcription :text
#  title_transcription             :text
#  valid_until                     :datetime
#  volume_number                   :integer
#  volume_number_string            :string
#  width                           :integer
#  year_of_publication             :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  carrier_type_id                 :bigint           default(1), not null
#  content_type_id                 :bigint           default(1)
#  frequency_id                    :bigint           default(1), not null
#  language_id                     :bigint           default(1), not null
#  nii_type_id                     :bigint
#  required_role_id                :bigint           default(1), not null
#
# Indexes
#
#  index_manifestations_on_access_address            (access_address)
#  index_manifestations_on_date_of_publication       (date_of_publication)
#  index_manifestations_on_manifestation_identifier  (manifestation_identifier)
#  index_manifestations_on_nii_type_id               (nii_type_id)
#  index_manifestations_on_updated_at                (updated_at)
#
# Foreign Keys
#
#  fk_rails_...  (required_role_id => roles.id)
#
