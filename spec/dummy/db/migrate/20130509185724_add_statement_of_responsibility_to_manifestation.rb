class AddStatementOfResponsibilityToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :statement_of_responsibility, :text
  end
end
