class CreateAgentNames < ActiveRecord::Migration[5.1]
  def change
    create_table :agent_names do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :full_name, index: true
      t.references :language, index: true
      t.references :agent, index: true
      t.references :profile, index: true
      t.integer :position
      t.string :source
      t.string :name_type

      t.timestamps null: false
    end
  end
end
