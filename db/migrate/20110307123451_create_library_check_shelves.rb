class CreateLibraryCheckShelves < ActiveRecord::Migration
  def self.up
    create_table :library_check_shelves do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :library_check_shelves
  end
end
