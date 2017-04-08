class CreateDemands < ActiveRecord::Migration[5.0]
  def change
    create_table :demands do |t|
      t.references :user, index: true
      t.references :item, index: true
      t.references :message, index: true

      t.timestamps null: false
    end
  end
end
