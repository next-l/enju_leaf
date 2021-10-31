class CreateSubjects < ActiveRecord::Migration[4.2]
  def self.up
    create_table :subjects do |t|
      t.references :parent, index: true
      t.integer :use_term_id
      t.string :term
      t.text :term_transcription
      t.references :subject_type, index: true, null: false
      t.text :scope_note
      t.text :note
      t.references :required_role, index: true, default: 1, null: false
      t.integer :lock_version, default: 0, null: false
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :deleted_at
    end
    add_index :subjects, :term
    add_index :subjects, :use_term_id
  end

  def self.down
    drop_table :subjects
  end
end
