class CreateSubjectHeadingTypes < ActiveRecord::Migration[4.2]
  def up
    create_table :subject_heading_types do |t|
      t.string :name, null: false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end

  def down
    drop_table :subject_heading_types
  end
end
