class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table :subjects do |t|
      t.integer :parent_id
      t.integer :use_term_id
      t.string :term
      t.text :term_transcription
      t.integer :subject_type_id, :null => false
      t.text :scope_note
      t.text :note
      t.integer :required_role_id, :default => 1, :null => false
      t.integer :work_has_subjects_count, :default => 0, :null => false
      t.integer :lock_version, :default => 0, :null => false
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :deleted_at
    end
    add_index :subjects, :term
    add_index :subjects, :parent_id
    add_index :subjects, :use_term_id
    add_index :subjects, :subject_type_id
  end

  def self.down
    drop_table :subjects
  end
end
