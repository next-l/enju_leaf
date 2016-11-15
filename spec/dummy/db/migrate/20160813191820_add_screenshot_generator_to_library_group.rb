class AddScreenshotGeneratorToLibraryGroup < ActiveRecord::Migration
  def change
    add_column :library_groups, :screenshot_generator, :string
  end
end
