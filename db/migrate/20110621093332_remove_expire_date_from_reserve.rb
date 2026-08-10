class RemoveExpireDateFromReserve < ActiveRecord::Migration[4.2]
  def up
    remove_column :reserves, :expire_date
  end

  def down
    add_column :reserves, :expire_date, :string
  end
end
