class AddMonthOfPublicationToManifestation < ActiveRecord::Migration[4.2]
  def change
    add_column :manifestations, :month_of_publication, :integer
  end
end
