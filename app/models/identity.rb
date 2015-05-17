class Identity < OmniAuth::Identity::Models::ActiveRecord
  validates :name, presence: :name
  validates :password, length: {minimum: 8}

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
