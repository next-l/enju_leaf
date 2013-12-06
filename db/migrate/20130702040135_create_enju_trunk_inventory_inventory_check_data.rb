class CreateEnjuTrunkInventoryInventoryCheckData < ActiveRecord::Migration
  def change
    create_table :inventory_check_data do |t|
      t.integer :inventory_manage_id, :null => false
      t.string :readcode, :null => false
      t.timestamp :read_at

      t.timestamps
    end
  end
end
