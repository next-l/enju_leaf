class CreatePatronMergeLists < ActiveRecord::Migration
  def change
    create_table :patron_merge_lists do |t|
      t.string :title

      t.timestamps
    end
  end
end
