class RemoveCounterCache20111012 < ActiveRecord::Migration
  def up
    remove_column :manifestations, :produces_count
    remove_column :manifestations, :exemplifies_count
    remove_column :manifestations, :embodies_count
    remove_column :manifestations, :work_has_subjects_count
    remove_column :items, :resource_has_subjects_count
    remove_column :patrons, :creates_count
    remove_column :patrons, :realizes_count
    remove_column :patrons, :produces_count
    remove_column :patrons, :owns_count
    remove_column :subjects, :work_has_subjects_count
  end

  def down
    add_column :manifestations, :produces_count, :default => 0, :null => false
    add_column :manifestations, :exemplifies_count, :default => 0, :null => false
    add_column :manifestations, :embodies_count, :default => 0, :null => false
    add_column :manifestations, :work_has_subjects_count, :default => 0, :null => false
    add_column :items, :resource_has_subjects_count, :default => 0, :null => false
    add_column :patrons, :creates_count, :default => 0, :null => false
    add_column :patrons, :realizes_count, :default => 0, :null => false
    add_column :patrons, :produces_count, :default => 0, :null => false
    add_column :patrons, :owns_count, :default => 0, :null => false
    add_column :subjects, :work_has_subjects_count, :default => 0, :null => false
  end
end
