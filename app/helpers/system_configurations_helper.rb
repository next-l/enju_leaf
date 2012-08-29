module SystemConfigurationsHelper
  def system_configuration_categories
    system_configuration_categories = [
      'general', 
      'user', 
      'manifestation', 
      'checkout', 
      'checkin', 
      'reserve', 
      'purchase_request',
      'question', 
      'order_list',
      'reminder', 
      'statistics', 
      'sound', 
    ]
  end

  def i18n_system_configuration_categories(category)
    case category
    when 'general'
      t('system_configuration.general')
    when 'user'
      t('system_configuration.user')
    when 'manifestation'
      t('system_configuration.manifestation')
    when 'checkout'
      t('system_configuration.checkin')
    when 'checkin'
      t('system_configuration.checkout')
    when 'reserve'
      t('system_configuration.reserve')
    when 'purchase_request'
      t('system_configuration.purchase_request')
    when 'question'
      t('system_configuration.question')
    when 'order_list'
      t('system_configuration.order_list')
    when 'reminder'
      t('system_configuration.reminder')
    when 'statistics'
      t('system_configuration.statistics')
    when 'sound'
      t('system_configuration.sound')
    end
  end
end
