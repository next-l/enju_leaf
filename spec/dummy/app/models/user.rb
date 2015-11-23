class User < ActiveRecord::Base
  devise :database_authenticatable, #:registerable,
    :recoverable, :rememberable, :trackable, #, :validatable
    :lockable, :lock_strategy => :none, :unlock_strategy => :none

  include EnjuLeaf::EnjuUser
  include EnjuMessage::EnjuUser
  include EnjuCirculation::EnjuUser
  enju_bookmark_user_model
end
