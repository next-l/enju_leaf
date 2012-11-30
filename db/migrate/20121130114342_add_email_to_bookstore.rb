class AddEmailToBookstore < ActiveRecord::Migration
  def change
    add_column :bookstores, :email, :string
  end
end
