class RemoveRequiredScoreFromAgents < ActiveRecord::Migration[7.2]
  def change
    remove_column :agents, :required_score, :integer, default: 0, null: false
    remove_column :items, :required_score, :integer, default: 0, null: false
    remove_column :manifestations, :required_score, :integer, default: 0, null: false
  end
end
