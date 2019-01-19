class AddNotNullToPositionOnCarrierType < ActiveRecord::Migration[5.2]
  def change
    change_column :carrier_types, :position, :integer, null: false, default: 1
    change_column :content_types, :position, :integer, null: false, default: 1
    change_column :frequencies, :position, :integer, null: false, default: 1
    change_column :licenses, :position, :integer, null: false, default: 1
    change_column :creates, :position, :integer, null: false, default: 1
    change_column :realizes, :position, :integer, null: false, default: 1
    change_column :produces, :position, :integer, null: false, default: 1
    change_column :owns, :position, :integer, null: false, default: 1
    change_column :form_of_works, :position, :integer, null: false, default: 1
    change_column :agent_types, :position, :integer, null: false, default: 1
  end
end
