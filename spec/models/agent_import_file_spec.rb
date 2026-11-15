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
      expect(@file.current_state).to eq 'pending'
      expect(@file.import_start).to eq({ agent_imported: 3, user_imported: 0, failed: 0 })
      expect(Agent.order('id DESC')[0].full_name).to eq '原田 ushi 隆史'
      expect(Agent.order('id DESC')[1].full_name).to eq '田辺浩介'
      expect(Agent.order('id DESC')[2].date_of_birth).to eq Time.zone.parse('1978-01-01')
      expect(Agent.count).to eq old_agents_count + 3
      expect(@file.agent_import_results.order(:id).first.body.split("\t").first).to eq 'full_name'
      expect(AgentImportResult.count).to eq old_import_results_count + 5

      expect(@file.executed_at).to be_truthy
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
      expect(@file.current_state).to eq 'pending'
      expect(@file.import_start).to eq({ agent_imported: 4, user_imported: 0, failed: 0 })
      expect(Agent.count).to eq old_agents_count + 4
      expect(Agent.order('id DESC')[0].full_name).to eq '原田 ushi 隆史'
      expect(Agent.order('id DESC')[1].full_name).to eq '田辺浩介'
      expect(AgentImportResult.count).to eq old_import_results_count + 5

      expect(@file.executed_at).to be_truthy
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
      expect(agent_1.full_name).to eq 'たなべこうすけ'
      expect(agent_1.address_1).to eq '東京都'
      agent_2 = Agent.find(2)
      expect(agent_2.full_name).to eq '田辺浩介'
      expect(agent_2.address_1).to eq '岡山県'
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
      expect(Agent.count).to eq old_count - 7
    end
  end

  it "should import in background" do
    file = AgentImportFile.create attachment: fixture_file_upload("agent_import_file_sample1.tsv")
    file.user = users(:admin)
    file.save
    expect(AgentImportFileJob.perform_later(file)).to be_truthy
  end
end

# ## Schema Information
#
# Table name: `agent_import_files`
#
# ### Columns
#
# Name                            | Type               | Attributes
# ------------------------------- | ------------------ | ---------------------------
# **`id`**                        | `bigint`           | `not null, primary key`
# **`agent_import_fingerprint`**  | `string`           |
# **`edit_mode`**                 | `string`           |
# **`error_message`**             | `text`             |
# **`executed_at`**               | `datetime`         |
# **`note`**                      | `text`             |
# **`user_encoding`**             | `string`           |
# **`created_at`**                | `datetime`         | `not null`
# **`updated_at`**                | `datetime`         | `not null`
# **`user_id`**                   | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_agent_import_files_on_user_id`:
#     * **`user_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
