class AddVolumeNumberToManifestation < ActiveRecord::Migration[4.2]
  def up
    add_column :manifestations, :volume_number, :integer
    add_column :manifestations, :issue_number, :integer
    add_column :manifestations, :serial_number, :integer
  end

  def down
    remove_column :manifestations, :serial_number
    remove_column :manifestations, :issue_number
    remove_column :manifestations, :volume_number
  end
end
