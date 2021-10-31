class AddUrlToSubject < ActiveRecord::Migration[4.2]
  def change
    add_column :subjects, :url, :string
  end
end
