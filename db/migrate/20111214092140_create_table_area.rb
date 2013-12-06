class CreateTableArea < ActiveRecord::Migration
  def self.up
    create_table :areas do |t|
      t.string :name
      t.text :address
    end
  end

  def self.down
    drop_table :areas
  end
end
