class CreateTerms < ActiveRecord::Migration
  def self.up
    create_table :terms do |t|
      t.string :display_name
      t.datetime :start_at
      t.datetime :end_at
    end
  end

  def self.down
    drop_table :terms
  end
end
