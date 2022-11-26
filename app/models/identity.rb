class Identity < ApplicationRecord
  belongs_to :profile
  validates :name, presence: true, uniqueness: {scope: :provider}
  validates :provider, presence: true

  def self.find_for_oauth(auth)
    where(name: auth.uid, provider: auth.provider).first_or_create
  end
end

# == Schema Information
#
# Table name: identities
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  email           :string
#  password_digest :string
#  profile_id      :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  provider        :string
#
