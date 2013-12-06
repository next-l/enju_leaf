class CreateSequenceManages < ActiveRecord::Migration
  def change
    create_table :sequence_manages do |t|
      t.string :keystr
      t.integer :value
      t.string :prefix
      t.string :note

      t.timestamps
    end
    add_index :sequence_manages, [:keystr]
  end
end
