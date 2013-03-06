class RenameManifestationNumberListToNumberString < ActiveRecord::Migration
  def self.up
    rename_column :manifestations, :volume_number_list, :volume_number_string
    rename_column :manifestations, :issue_number_list, :issue_number_string
    rename_column :manifestations, :serial_number_list, :serial_number_string
  end

  def self.down
    rename_column :manifestations, :serial_number_string, :serial_number_list
    rename_column :manifestations, :issue_number_string, :issue_number_list
    rename_column :manifestations, :volume_number_string, :volume_number_list
  end
end
