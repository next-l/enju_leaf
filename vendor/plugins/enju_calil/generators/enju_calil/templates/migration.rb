class EnjuCalilAddNeighborhoodCalilSystemidTo<%= table_name.camelize %> < ActiveRecord::Migration
  def self.up
    add_column :<%= table_name %>, :calil_systemid, :string
    add_column :<%= table_name %>, :calil_neighborhood_systemid, :text
  end

  def self.down
    remove_column :<%= table_name %>, :calil_systemid
    remove_column :<%= table_name %>, :calil_neighborhood_systemid
  end
end
