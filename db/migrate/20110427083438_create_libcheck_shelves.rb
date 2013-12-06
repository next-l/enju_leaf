class CreateLibcheckShelves < ActiveRecord::Migration
  def self.up
    create_table(:libcheck_shelves) do |t|
      t.string :shelf_name, :null => false
      t.string :stack_id
      t.string :shelf_grp_id
      t.timestamps
    end
  end
  def self.down
    drop_table :libcheck_shelves
  end
end

