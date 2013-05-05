class AddSubjectHeadingTypeIdToSubject < ActiveRecord::Migration
  def change
    add_column :subjects, :subject_heading_type_id, :integer
  end
end
