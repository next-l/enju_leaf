class AddScreenshotGeneratorToLibraryGroup < ActiveRecord::Migration[5.0]
  def change
    add_column :library_groups, :screenshot_generator, :string
  end
end
