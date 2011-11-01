class Family < ActiveRecord::Base
  has_many :users, :through => :family_users
  has_many :family_users

  def add_user(user_ids)
    user_ids.each do |user_id|
      self.users << User.find(user_id) rescue nil
    end
  end
end
