class CreateSubjectHasClassifications < ActiveRecord::Migration
  def self.up
    create_table :subject_has_classifications do |t|
      t.references :subject, :polymorphic => true
      t.integer :classification_id, :null => false

      t.timestamps
    end
    add_index :subject_has_classifications, :subject_id
    add_index :subject_has_classifications, :classification_id
  end

  def self.down
    drop_table :subject_has_classifications
  end
end
