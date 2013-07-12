class AddIndexForImport < ActiveRecord::Migration
  def up
    add_index :creates, :id
    add_index :subjects, :id
    add_index :items, :call_number
    add_index :manifestations, :original_title
    add_index :manifestations, :article_title
    add_index :manifestations, :pub_date
    add_index :manifestations, :start_page
    add_index :manifestations, :end_page
    add_index :manifestations, :volume_number_string
    add_index :manifestations, :issue_number_string
  end

  def down
    remove_index :creates, :id
    remove_index :subjects, :id
    remove_index :items, :call_number
    remove_index :manifestations, :original_title
    remove_index :manifestations, :article_title
    remove_index :manifestations, :pub_date
    remove_index :manifestations, :start_page
    remove_index :manifestations, :end_page
    remove_index :manifestations, :volume_number_string
    remove_index :manifestations, :issue_number_string
  end
end
