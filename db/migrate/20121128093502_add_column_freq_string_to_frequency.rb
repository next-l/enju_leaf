class AddColumnFreqStringToFrequency < ActiveRecord::Migration
  def change
    add_column :frequencies, :freq_string, :string
    add_column :frequencies, :nii_code, :string
    add_index :frequencies, :nii_code
  end
end
