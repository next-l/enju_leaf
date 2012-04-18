class AddMonthOfPublicationToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :month_of_publication, :integer
  end
end
