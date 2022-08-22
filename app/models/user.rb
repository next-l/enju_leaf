class User < ApplicationRecord
  devise :two_factor_authenticatable, :two_factor_backupable,
         :otp_secret_encryption_key => ENV['ENJU_LEAF_2FA_ENCRYPTION_KEY']

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :registerable,
         :recoverable, :rememberable, :lockable
  include EnjuSeed::EnjuUser
  include EnjuCirculation::EnjuUser
  include EnjuMessage::EnjuUser
  include EnjuBookmark::EnjuUser
end

# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  email                     :string           default(""), not null
#  encrypted_password        :string           default(""), not null
#  reset_password_token      :string
#  reset_password_sent_at    :datetime
#  remember_created_at       :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  username                  :string
#  expired_at                :datetime
#  failed_attempts           :integer          default(0)
#  unlock_token              :string
#  locked_at                 :datetime
#  confirmed_at              :datetime
#  encrypted_otp_secret      :string
#  encrypted_otp_secret_iv   :string
#  encrypted_otp_secret_salt :string
#  consumed_timestep         :integer
#  otp_required_for_login    :boolean          default(FALSE), not null
#  otp_backup_codes          :string           is an Array
#
