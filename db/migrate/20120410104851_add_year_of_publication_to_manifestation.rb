class AddYearOfPublicationToManifestation < ActiveRecord::Migration[4.2]
  def change
    add_column :manifestations, :year_of_publication, :integer
  end
end
