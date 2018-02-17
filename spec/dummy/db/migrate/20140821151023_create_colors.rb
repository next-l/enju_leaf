class CreateColors < ActiveRecord::Migration[5.1]
  def change
    create_table :colors do |t|
      t.references :library_group
      t.string :property, null: false
      t.string :code, null: false
      t.integer :position

      t.timestamps
    end
  end
end
