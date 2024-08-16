class AddOpeningHourToLibrary < ActiveRecord::Migration[4.2]
  def up
    add_column :libraries, :opening_hour, :text
  end

  def down
    remove_column :libraries, :opening_hour
  end
end
