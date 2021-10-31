class CreatePlaces < ActiveRecord::Migration[4.2]
  def change
    create_table :places do |t|
      t.string :term
      t.text :city
      t.references :country, index: true
      t.float :latitude
      t.float :longitude

      t.timestamps null: false
    end
    add_index :places, :term
  end
end
