class RenamePatronToAgent < ActiveRecord::Migration
  def up
    rename_table :patrons, :agents
    rename_table :patron_types, :agent_types
    rename_table :patron_relationships, :agent_relationships
    rename_table :patron_relationship_types, :agent_relationship_types
    rename_table :patron_import_files, :agent_import_files
    rename_table :patron_import_results, :agent_import_results
    #rename_table :patron_merge_lists, :agent_merge_lists
    #rename_table :patron_merges, :agent_merges
    rename_column :creates, :patron_id, :agent_id
    rename_column :realizes, :patron_id, :agent_id
    rename_column :produces, :patron_id, :agent_id
    rename_column :owns, :patron_id, :agent_id
    rename_column :donates, :patron_id, :agent_id
    #rename_column :agent_merges, :patron_id, :agent_id
    rename_column :participates, :patron_id, :agent_id
    rename_column :agents, :patron_type_id, :agent_type_id
    rename_column :agents, :patron_identifier, :agent_identifier
    rename_index :creates, "index_creates_on_patron_id", "index_creates_on_agent_id"
    rename_index :realizes, "index_realizes_on_patron_id", "index_realizes_on_agent_id"
    rename_index :produces, "index_produces_on_patron_id", "index_produces_on_agent_id"
    rename_index :owns, "index_owns_on_patron_id", "index_owns_on_agent_id"
    rename_index :participates, "index_participates_on_patron_id", "index_participates_on_agent_id"
  end

  def down
    rename_table :agents, :patrons
    rename_table :agent_types, :patron_types
    rename_table :agent_relationships, :patron_relationships
    rename_table :agent_relationship_types, :patron_relationship_types
    rename_table :agent_import_files, :patron_import_files
    rename_table :agent_import_results, :patron_import_results
    #rename_table :agent_merge_lists, :patron_merge_lists
    #rename_table :agent_merges, :patron_merges
    rename_column :patrons, :agent_type_id, :patron_type_id
    rename_column :patrons, :agent_identifier, :patron_identifier
    rename_column :creates, :agent_id, :patron_id
    rename_column :realizes, :agent_id, :patron_id
    rename_column :produces, :agent_id, :patron_id
    rename_column :owns, :agent_id, :patron_id
    rename_column :donates, :agent_id, :patron_id
    #rename_column :patron_merges, :agent_id, :patron_id
    rename_column :participates, :agent_id, :patron_id
    rename_index :creates, "index_creates_on_agent_id", "index_creates_on_patron_id"
    rename_index :realizes, "index_realizes_on_agent_id", "index_realizes_on_patron_id"
    rename_index :produces, "index_produces_on_agent_id", "index_produces_on_patron_id"
    rename_index :owns, "index_owns_on_agent_id", "index_owns_on_patron_id"
    rename_index :participates, "index_participates_on_agent_id", "index_participates_on_patron_id"
  end
end
