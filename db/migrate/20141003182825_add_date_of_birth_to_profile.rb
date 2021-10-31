class AddDateOfBirthToProfile < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :date_of_birth, :datetime
  end
end
