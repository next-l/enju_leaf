class AddMonthOfPublicationToManifestation < ActiveRecord::Migration[5.1]
  def change
    add_column :manifestations, :month_of_publication, :integer
  end
end
