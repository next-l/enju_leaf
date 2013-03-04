class AddColumnDateOfPublicationStringToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :date_of_publication_string, :string
  end
end
