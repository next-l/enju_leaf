module InterLibraryLoansHelper
  def i18n_loan_state(state)
    case state
    when 'pending'
      t('inter_library_loan.pending')
    when 'requested'
      t('inter_library_loan.requested')
    when 'shipped'
      t('inter_library_loan.shipped')
    when 'received'
      t('inter_library_loan.received')
    end
  end
end
