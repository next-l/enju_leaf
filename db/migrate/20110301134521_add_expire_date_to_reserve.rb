class AddExpireDateToReserve < ActiveRecord::Migration[4.2]
  def up
    add_column :reserves, :expire_date, :string
  end

  def down
    remove_column :reserves, :expire_date
  end
end
