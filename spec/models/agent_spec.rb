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
      agent_list = [{full_name: "Agent 1"}, {full_name: "Agent 2"}]
      agents = Agent.import_agents(agent_list)
      expect(agents).to be_truthy
      expect(agents.first).to be_truthy
      expect(agents.first.full_name).to eq "Agent 1"
      expect(agents.last).to be_truthy
      expect(agents.last.full_name).to eq "Agent 2"
    end
    it "should import place" do
      agent_list = [{full_name: "Agent 1", place: "place"}]
      agents = Agent.import_agents(agent_list)
      expect(agents.first).to be_truthy
      expect(agents.first.place).to eq "place"
    end
    it "should unique the same agent" do
      agent_list = [{full_name: "Agent 1", place: "place"}, {full_name: "Agent 1"}]
      agents = Agent.import_agents(agent_list)
      expect(agents.size).to be 1
    end
    it "should distinguish the agents even with the same full_name" do
      agent_list = [{full_name: "Agent 1", place: "place 1"}, {full_name: "Agent 1", place: "place 2"}]
      agents = Agent.import_agents(agent_list)
      expect(agents.size).to be 2
    end
  end
end

# == Schema Information
#
# Table name: agents
#
#  id                                  :integer          not null, primary key
#  last_name                           :string
#  middle_name                         :string
#  first_name                          :string
#  last_name_transcription             :string
#  middle_name_transcription           :string
#  first_name_transcription            :string
#  corporate_name                      :string
#  corporate_name_transcription        :string
#  full_name                           :string
#  full_name_transcription             :text
#  full_name_alternative               :text
#  created_at                          :datetime
#  updated_at                          :datetime
#  zip_code_1                          :string
#  zip_code_2                          :string
#  address_1                           :text
#  address_2                           :text
#  address_1_note                      :text
#  address_2_note                      :text
#  telephone_number_1                  :string
#  telephone_number_2                  :string
#  fax_number_1                        :string
#  fax_number_2                        :string
#  other_designation                   :text
#  place                               :text
#  postal_code                         :string
#  street                              :text
#  locality                            :text
#  region                              :text
#  date_of_birth                       :datetime
#  date_of_death                       :datetime
#  language_id                         :integer          default(1), not null
#  country_id                          :integer          default(1), not null
#  agent_type_id                       :integer          default(1), not null
#  lock_version                        :integer          default(0), not null
#  note                                :text
#  required_role_id                    :integer          default(1), not null
#  required_score                      :integer          default(0), not null
#  email                               :text
#  url                                 :text
#  full_name_alternative_transcription :text
#  birth_date                          :string
#  death_date                          :string
#  agent_identifier                    :string
#  profile_id                          :integer
#
