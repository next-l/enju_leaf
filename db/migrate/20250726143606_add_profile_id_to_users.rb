class AddProfileIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :profile, null: true, foreign_key: true
    if Profile.column_names.include?("user_id")
      Profile.where.not(user_id: nil).each do |profile|
        user = User.find_by(id: profile.user_id)
        next unless user

        user.update_column(:profile_id, profile.id)
      end

      remove_column :profiles, :user_id, :integer
    end

    User.where(profile_id: nil).each do |user|
      user.create_profile!(
        full_name: user.username,
        library: Library.real.order(:position).first,
        user_group: UserGroup.order(:position).first
      )
    end

    User.where(profile_id: nil).each do |user|
      user.create_profile!(
        full_name: user.username,
        library: Library.real.order(:position).first,
        user_group: UserGroup.order(:position).first
      )
    end

    change_column_null :users, :profile_id, false
  end
end
