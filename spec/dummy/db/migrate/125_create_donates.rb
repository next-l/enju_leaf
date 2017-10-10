class CreateDonates < ActiveRecord::Migration[5.1]
  def change
    create_table :donates do |t|
      t.references :agent, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: :true, type: :uuid

      t.timestamps
    end
  end
end
