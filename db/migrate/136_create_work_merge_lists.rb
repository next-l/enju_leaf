class CreateWorkMergeLists < ActiveRecord::Migration
  def change
    create_table :work_merge_lists do |t|
      t.string :title

      t.timestamps
    end
  end
end
