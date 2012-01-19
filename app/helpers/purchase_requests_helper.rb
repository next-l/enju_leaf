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
end
