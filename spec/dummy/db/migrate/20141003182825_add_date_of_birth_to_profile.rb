class AddDateOfBirthToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :date_of_birth, :datetime
  end
end
