class AddItemIdentifierToAnswer < ActiveRecord::Migration
  def self.up
    add_column :answers, :item_identifier_list, :text
    add_column :answers, :url_list, :text
  end

  def self.down
    remove_column :answers, :url_list
    remove_column :answers, :item_identifier_list
  end
end
