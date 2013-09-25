module ThemasHelper

  def i18n_publish(number)
    case number
    when 0
      return I18n.t('resource.publish')
    when 1
      return I18n.t('resource.closed')
    end
  end


end
