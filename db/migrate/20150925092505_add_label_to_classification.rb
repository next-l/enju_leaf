class AddLabelToClassification < ActiveRecord::Migration[4.2]
  def change
    add_column :classifications, :label, :string
  end
end
