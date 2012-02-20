class BudgetAndResultsManagementsController < ApplicationController
  def index
    @term = Term.current_term
    @terms = Term.find(:all, :order => "start_at")
    @results = []
    
    if params[:id]
      term_id = params[:id]
      logger.info "term id=#{term_id}}"

      term = Term.find(term_id)
      term_start_yyyymm = term.start_at.strftime("%Y%m")
      term_end_yyyymm = term.end_at.strftime("%Y%m")
      @budgets = Budget.find_all_by_term_id(term_id)
      @expenses = Expense.where("create_at_yyyymm BETWEEN ? AND ?", term_start_yyyymm, term_end_yyyymm).group(:create_at_yyyymm).sum(:price)
      #TODO
      @budgets.each do |b|
        r = {}
        r[:item_of_expenditure] = 'budget'
        r[:budget] = b.amount
        r[:created_at] = b.created_at
        @results << r
      end
      @expenses.each do |k, v|
        r = {}
        r[:item_of_expenditure] = "#{k}"
        r[:expense] = v
        r[:created_at] = "#{k}00"
        @results << r
      end

      pp @results
      #@results = @results.sort{|a, b| a[:created_at] <=> b[:created_at]}
    end
  end
end
