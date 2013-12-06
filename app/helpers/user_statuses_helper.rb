module UserStatusesHelper
  def state(id)
    case id
    when 1
      t('user_status.general')
    when 2
      t('user_status.guest')
    when 3
      t('user_status.suspended')
    end
  end
end
