class AddIndexForImport2 < ActiveRecord::Migration
  def up
    remove_index :manifestations, :original_title
    remove_index :manifestations, :article_title
    remove_index :manifestations, :pub_date
    remove_index :manifestations, :start_page
    remove_index :manifestations, :end_page
    remove_index :manifestations, :volume_number_string
    remove_index :manifestations, :issue_number_string
    add_index :series_statements, :original_title
    add_index :manifestations, [:original_title, :pub_date], :name => 'index_1'
  end
  
  def down
    add_index :manifestations, :original_title
    add_index :manifestations, :article_title
    add_index :manifestations, :pub_date
    add_index :manifestations, :start_page
    add_index :manifestations, :end_page
    add_index :manifestations, :volume_number_string
    add_index :manifestations, :issue_number_string
    remove_index :series_statements, :original_title
    remove_index :manifestations, :name => 'index_1'
  end
end
