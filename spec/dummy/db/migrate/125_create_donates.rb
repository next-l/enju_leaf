class CreateDonates < ActiveRecord::Migration[5.2]
  def change
    create_table :donates do |t|
      t.references :agent, foreign_key: true, null: false, type: :uuid
      t.references :item, foreign_key: true, null: false, type: :uuid

      t.timestamps
    end
  end
end
