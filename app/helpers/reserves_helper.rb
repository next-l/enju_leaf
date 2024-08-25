module ReservesHelper
  include ManifestationsHelper rescue nil
  def i18n_state(state)
    case state
    when 'pending'
      t('reserve.pending')
    when 'requested'
      t('reserve.requested')
    when 'retained'
      t('reserve.retained')
    when 'canceled'
      t('reserve.canceled')
    when 'expired'
      t('reserve.expired')
    when 'postponed'
      t('reserve.postponed')
    when 'completed'
      t('reserve.completed')
    end
  end

  def filtered_params
    params.permit([:user_id, :reserved_from, :reserved_until, :query, :sort_by, :state])
  end
end
