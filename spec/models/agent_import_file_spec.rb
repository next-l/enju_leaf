require 'rails_helper'

describe AgentImportFile do
  fixtures :all

  describe "when its mode is 'create'" do
    before(:each) do
      @file = AgentImportFile.create! attachment: fixture_file_upload("agent_import_file_sample1.tsv"), user: users(:admin)
    end

    it "should be imported" do
      old_agents_count = Agent.count
      old_import_results_count = AgentImportResult.count
      @file.current_state.should eq 'pending'
      @file.import_start.should eq({agent_imported: 3, user_imported: 0, failed: 0})
      Agent.order('id DESC')[0].full_name.should eq '原田 ushi 隆史'
      Agent.order('id DESC')[1].full_name.should eq '田辺浩介'
      Agent.order('id DESC')[2].date_of_birth.should eq Time.zone.parse('1978-01-01')
      Agent.count.should eq old_agents_count + 3
      @file.agent_import_results.order(:id).first.body.split("\t").first.should eq 'full_name'
      AgentImportResult.count.should eq old_import_results_count + 5

      @file.executed_at.should be_truthy
    end
  end

  describe "when it is written in shift_jis" do
    before(:each) do
      @file = AgentImportFile.create!(
        attachment: fixture_file_upload("agent_import_file_sample3.tsv"),
        user: users(:admin)
      )
    end

    it "should be imported" do
      old_agents_count = Agent.count
      old_import_results_count = AgentImportResult.count
      @file.current_state.should eq 'pending'
      @file.import_start.should eq({agent_imported: 4, user_imported: 0, failed: 0})
      Agent.count.should eq old_agents_count + 4
      Agent.order('id DESC')[0].full_name.should eq '原田 ushi 隆史'
      Agent.order('id DESC')[1].full_name.should eq '田辺浩介'
      AgentImportResult.count.should eq old_import_results_count + 5

      @file.executed_at.should be_truthy
    end
  end

  describe "when its mode is 'update'" do
    it "should update users" do
      file = AgentImportFile.create!(
        attachment: fixture_file_upload("agent_update_file.tsv"),
        user: users(:admin)
      )
      file.modify
      agent_1 = Agent.find(1)
      agent_1.full_name.should eq 'たなべこうすけ'
      agent_1.address_1.should eq '東京都'
      agent_2 = Agent.find(2)
      agent_2.full_name.should eq '田辺浩介'
      agent_2.address_1.should eq '岡山県'
    end
  end

  describe "when its mode is 'destroy'" do
    it "should remove users" do
      old_count = Agent.count
      file = AgentImportFile.create!(
        attachment: fixture_file_upload("agent_delete_file.tsv"),
        user: users(:admin)
      )
      file.remove
      Agent.count.should eq old_count - 7
    end
  end

  it "should import in background" do
    file = AgentImportFile.create attachment: fixture_file_upload("agent_import_file_sample1.tsv")
    file.user = users(:admin)
    file.save
    AgentImportFileJob.perform_later(file).should be_truthy
  end
end

# == Schema Information
#
# Table name: agent_import_files
#
#  id                        :bigint           not null, primary key
#  parent_id                 :integer
#  content_type              :string
#  size                      :integer
#  user_id                   :bigint
#  note                      :text
#  executed_at               :datetime
#  agent_import_file_name    :string
#  agent_import_content_type :string
#  agent_import_file_size    :integer
#  agent_import_updated_at   :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  agent_import_fingerprint  :string
#  error_message             :text
#  edit_mode                 :string
#  user_encoding             :string
#
