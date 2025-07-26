class AddIndexToProducesOnManifestationIdAndAgentId < ActiveRecord::Migration[6.1]
  def change
    remove_index :produces, :manifestation_id
    add_index :produces, [:manifestation_id, :agent_id], unique: true
  end
end
