class UpdateStatistics < ActiveRecord::Migration
  def self.up
    add_column :statistics, :checkout_type_id, :integer
    add_column :statistics, :shelf_id, :integer
    add_column :statistics, :ndc, :string
    add_column :statistics, :call_number, :string
    add_column :statistics, :age, :integer
    add_column :statistics, :option, :integer
  end

  def self.down
    remove_column :statistics, :checkout_type_id
    remove_column :statistics, :shelf_id
    remove_column :statistics, :ndc
    remove_column :statistics, :call_number
    remove_column :statistics, :age
    remove_column :statistics, :option
  end
end
