class AddColumnToSubject < ActiveRecord::Migration
  def self.up
    add_column :subjects, :subject_identifier, :string
    add_index :subjects, :subject_identifier
  end

  def self.down
    remove_index :subjects, :subject_identifier
    remove_column :subjects, :subject_identifier
  end
end
