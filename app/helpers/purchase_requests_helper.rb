module PurchaseRequestsHelper
  def i18n_pr_state(state)
    case state
    when 'pending'
      t('purchase_request.pending')
    when 'accepted'
      t('purchase_request.not_ordered')
    when 'rejected'
      t('purchase_request.reject')
    when 'ordered'
      t('purchase_request.ordered')
    end
  end

  def can_use_purchase_request?
    role_can_use_purchase_request = SystemConfiguration.get("purchase_request.can_use")
    if role_can_use_purchase_request == ''
      return true
    else
      if user_signed_in?
        return true if current_user.has_role?(role_can_use_purchase_request)
      end
    end
    false
  end
end
