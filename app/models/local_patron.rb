class LocalPatron
  def initialize(user)
    @user = user
  end

  def id 
  end

  def full_name
    # TODO: 外部サービスから取得
    @user.email
  end
end
