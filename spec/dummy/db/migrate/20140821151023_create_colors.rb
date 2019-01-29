class CreateColors < ActiveRecord::Migration[5.2]
  def change
    create_table :colors do |t|
      t.references :library_group, foreign_key: true
      t.string :property
      t.string :code
      t.integer :position

      t.timestamps
    end
  end
end
