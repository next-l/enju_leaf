class Identity < ApplicationRecord
  belongs_to :profile
  validates :name, presence: true, uniqueness: { scope: :provider }
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
#  email           :string
#  name            :string           not null
#  password_digest :string
#  provider        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  profile_id      :bigint
#
# Indexes
#
#  index_identities_on_email       (email)
#  index_identities_on_name        (name)
#  index_identities_on_profile_id  (profile_id)
#
