class LocalPatron
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :username, :full_name, :address, :email

  def initialize(attributes = {})
    if attributes[:username]
      user = User.where(:username => attributes[:username]).first
      if user
        send('email=', user.email)
      end
    else
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
  end

  def persisted?
    false
  end

  def id
  end
end
