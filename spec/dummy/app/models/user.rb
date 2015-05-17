# -*- encoding: utf-8 -*-
class User < ActiveRecord::Base
  enju_leaf_user_model
  enju_message_user_model
  enju_circulation_user_model
  enju_bookmark_user_model

  def self.from_omniauth(auth)
    where(provider: auth["provider"], uid: auth["uid"]).first || create_with_omniauth(auth)
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.email = auth["info"]["email"]
      user.username = auth["info"]["name"]
    end
  end
end
