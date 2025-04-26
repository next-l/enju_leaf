FactoryBot.define do
  factory :agent do |f|
    f.sequence(:full_name) {|n| "full_name_#{n}"}
    f.agent_type_id {AgentType.find_by(name: 'person').id}
    f.country_id {Country.first.id}
    f.language_id {Language.first.id}
  end
end

FactoryBot.define do
  factory :invalid_agent, class: Agent do |f|
  end
end

# == Schema Information
#
# Table name: agents
#
#  id                                  :bigint           not null, primary key
#  address_1                           :text
#  address_1_note                      :text
#  address_2                           :text
#  address_2_note                      :text
#  agent_identifier                    :string
#  birth_date                          :string
#  corporate_name                      :string
#  corporate_name_transcription        :string
#  date_of_birth                       :datetime
#  date_of_death                       :datetime
#  death_date                          :string
#  email                               :text
#  fax_number_1                        :string
#  fax_number_2                        :string
#  first_name                          :string
#  first_name_transcription            :string
#  full_name                           :string
#  full_name_alternative               :text
#  full_name_alternative_transcription :text
#  full_name_transcription             :text
#  last_name                           :string
#  last_name_transcription             :string
#  locality                            :text
#  lock_version                        :integer          default(0), not null
#  middle_name                         :string
#  middle_name_transcription           :string
#  note                                :text
#  other_designation                   :text
#  place                               :text
#  postal_code                         :string
#  region                              :text
#  required_score                      :integer          default(0), not null
#  street                              :text
#  telephone_number_1                  :string
#  telephone_number_2                  :string
#  url                                 :text
#  zip_code_1                          :string
#  zip_code_2                          :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  agent_type_id                       :bigint           default(1), not null
#  country_id                          :bigint           default(1), not null
#  language_id                         :bigint           default(1), not null
#  profile_id                          :bigint
#  required_role_id                    :bigint           default(1), not null
#
# Indexes
#
#  index_agents_on_agent_identifier  (agent_identifier)
#  index_agents_on_country_id        (country_id)
#  index_agents_on_full_name         (full_name)
#  index_agents_on_language_id       (language_id)
#  index_agents_on_profile_id        (profile_id)
#  index_agents_on_required_role_id  (required_role_id)
#
# Foreign Keys
#
#  fk_rails_...  (required_role_id => roles.id)
#
