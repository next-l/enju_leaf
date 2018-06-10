class CreateColors < ActiveRecord::Migration[4.2]
  def change
    create_table :colors do |t|
      t.references :library_group, index: true
      t.string :property
      t.string :code
      t.integer :position

      t.timestamps
    end
  end
end
