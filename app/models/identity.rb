class Identity < ActiveRecord::Base
  belongs_to :profile
  validates :name, presence: true, uniqueness: {scope: :provider}
  validates :provider, presence: true

  def self.find_for_oauth(auth)
    where(name: auth.uid, provider: auth.provider).first_or_create
  end
end
