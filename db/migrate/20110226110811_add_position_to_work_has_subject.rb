class AddPositionToWorkHasSubject < ActiveRecord::Migration
  def self.up
    add_column :work_has_subjects, :position, :integer
  end

  def self.down
    remove_column :work_has_subjects, :position
  end
end
