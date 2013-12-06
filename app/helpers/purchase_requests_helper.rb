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
        case role_can_use_purchase_request
        when 'Guest'
          return true if ['Guest', 'User', 'Librarian', 'Administrator'].include?(current_user.role.name)
        when 'User'
          return true if ['User', 'Librarian', 'Administrator'].include?(current_user.role.name)
        when 'Librarian'
          return true if ['Librarian', 'Administrator'].include?(current_user.role.name)
        when 'Administrator'
          return true if ['Administrator'].include?(current_user.role.name)
        end
      end
    end
    false
  end
end
