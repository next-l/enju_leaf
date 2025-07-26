class AddProfileIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :profile, null: true, foreign_key: true
    Profile.where.not(user_id: nil).each do |profile|
      user = User.find_by(id: profile.user_id)
      next unless user

      user.update_column(:profile_id, profile.id)
    end

    change_column_null :users, :profile_id, false
  end
end
