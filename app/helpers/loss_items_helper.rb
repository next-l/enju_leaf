module LossItemsHelper
  def i18n_status(status)
    case status
    when 0
      t('activerecord.attributes.loss_item.not_reimbursed')
    when 1
      t('activerecord.attributes.loss_item.reimbursed')
    end
  end
end
