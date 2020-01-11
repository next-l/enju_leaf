class CreateSearchEngines < ActiveRecord::Migration[5.2]
  def change
    create_table :search_engines do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.text :base_url, null: false
      t.text :http_method, null: false
      t.text :query_param, null: false
      t.text :additional_param
      t.text :note, comment: '備考'
      t.integer :position

      t.timestamps
    end
  end
end
