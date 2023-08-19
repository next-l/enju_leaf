module OrderListHelper
  def localized_order_state(current_state)
    case current_state
    when 'pending'
      t('state.pending')
    when 'not_ordered'
      t('order_list.not_ordered')
    when 'ordered'
      t('order_list.ordered')
    end
  end
end
