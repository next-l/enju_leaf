class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable
  include EnjuSeed::EnjuUser
  include EnjuCirculation::EnjuUser
  include EnjuMessage::EnjuUser
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string
#  deleted_at             :datetime
#  expired_at             :datetime
#  failed_attempts        :integer          default(0)
#  unlock_token           :string
#  locked_at              :datetime
#  confirmed_at           :datetime
#
