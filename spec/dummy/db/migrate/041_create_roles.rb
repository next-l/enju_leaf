class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table "roles", comment: '権限' do |t|
      t.column :name, :string, null: false
      t.column :display_name, :string
      t.column :note, :text, comment: '備考'
      t.integer :position

      t.timestamps
    end
  end
end
