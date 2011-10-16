class AddSolvedToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :solved, :boolean, :null => false, :default => false
    add_column :questions, :note, :text
  end

  def self.down
    remove_column :questions, :note
    remove_column :questions, :solved
  end
end
