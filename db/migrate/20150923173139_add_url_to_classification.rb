class AddUrlToClassification < ActiveRecord::Migration[4.2]
  def change
    add_column :classifications, :url, :string
  end
end
