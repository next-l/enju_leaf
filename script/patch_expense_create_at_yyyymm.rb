#  RAILS_ENV=production ./script/rails runner script/patch_expense_create_at_yyyymm.rb 
logger = RAILS_DEFAULT_LOGGER
logger.info "Start batch"

Expense.all.each do |ex| 
  ex.create_at_yyyymm = ex.created_at.strftime("%Y%m") 
  ex.save!
end

logger.info "End batch"
