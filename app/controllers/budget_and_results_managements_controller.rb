class BudgetAndResultsManagementsController < ApplicationController
  def index
    @term = Term.current_term
    @terms = Term.find(:all, :order => "start_at")
    @results = []
    
    if params[:id]
      term_id = params[:id]
      logger.info "term id=#{term_id}}"

      term = Term.find(term_id)
      @budgets = Budget.find_all_by_term_id(term_id)
      @expense = Expense.where(["created_at between ? and ?", Term.find(12).start_at, Term.find(12).end_at])

    end
  end
end
