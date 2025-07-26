require 'rails_helper'

describe Agent do
  # pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it "should set a default required_role to Guest" do
    agent = FactoryBot.create(:agent)
    agent.required_role.should eq Role.find_by(name: 'Guest')
  end

  it "should set birth_date" do
    agent = FactoryBot.create(:agent, birth_date: '2000')
    agent.date_of_birth.should eq Time.zone.parse('2000-01-01')
  end

  it "should set death_date" do
    agent = FactoryBot.create(:agent, death_date: '2000')
    agent.date_of_death.should eq Time.zone.parse('2000-01-01')
  end

  it "should not set death_date earlier than birth_date" do
    agent = FactoryBot.create(:agent, birth_date: '2010', death_date: '2000')
    agent.should_not be_valid
  end

  it "should be creator" do
    agents(:agent_00001).creator?(manifestations(:manifestation_00001)).should be_truthy
  end

  it "should not be creator" do
    agents(:agent_00010).creator?(manifestations(:manifestation_00001)).should be_falsy
  end

  it "should be publisher" do
    agents(:agent_00001).publisher?(manifestations(:manifestation_00001)).should be_truthy
  end

  it "should not be publisher" do
    agents(:agent_00010).publisher?(manifestations(:manifestation_00001)).should be_falsy
  end

  describe ".import_agents" do
    it "should import agents" do
      agent_list = [ { full_name: "Agent 1" }, { full_name: "Agent 2" } ]
      agents = Agent.import_agents(agent_list)
      expect(agents).to be_truthy
      expect(agents.first).to be_truthy
      expect(agents.first.full_name).to eq "Agent 1"
      expect(agents.last).to be_truthy
      expect(agents.last.full_name).to eq "Agent 2"
    end
    it "should import place" do
      agent_list = [ { full_name: "Agent 1", place: "place" } ]
      agents = Agent.import_agents(agent_list)
      expect(agents.first).to be_truthy
      expect(agents.first.place).to eq "place"
    end
    it "should unique the same agent" do
      agent_list = [ { full_name: "Agent 1", place: "place" }, { full_name: "Agent 1" } ]
      agents = Agent.import_agents(agent_list)
      expect(agents.size).to be 1
    end
    it "should distinguish the agents even with the same full_name" do
      agent_list = [ { full_name: "Agent 1", place: "place 1" }, { full_name: "Agent 1", place: "place 2" } ]
      agents = Agent.import_agents(agent_list)
      expect(agents.size).to be 2
    end
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
