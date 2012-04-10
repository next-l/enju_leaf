class AddYearOfPublicationToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :year_of_publication, :integer
  end
end
