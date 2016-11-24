class CreateItemTransitions < ActiveRecord::Migration
  def change
    create_table :item_transitions do |t|
      t.string :to_state
      if ActiveRecord::Base.configurations[Rails.env]['adapter'].try(:match, /mysql/)
        t.text :metadata
      else
        t.text :metadata, default: '{}'
      end
      t.integer :sort_key
      t.integer :item_id
      t.timestamps
    end

    add_index :item_transitions, :item_id
    add_index :item_transitions, [:sort_key, :item_id], unique: true
  end
end
