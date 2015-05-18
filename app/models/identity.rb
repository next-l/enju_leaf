class Identity < OmniAuth::Identity::Models::ActiveRecord
  validates :name, presence: true
  validates :password, length: {minimum: 8}
  belongs_to :user
  auth_key 'name'

  def self.find_with_omniauth(auth)
    where(name: auth['info']['name'], provider: auth['provider']).first
  end

  def self.create_with_omniauth(auth)
    identity = Identity.new(name: auth['info']['name'], provider: auth['provider'])
    identity.set_auto_generated_password
    identity.save
    identity
  end

  def set_auto_generated_password
    self.password = KeePass::Password.generate('A{7}s')
  end
end

# == Schema Information
#
# Table name: identities
#
#  id              :integer          not null, primary key
#  name            :string
#  email           :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
