class AddJpnOrForeignToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :jpn_or_foreign, :integer
  end
end
