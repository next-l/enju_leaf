class BudgetAndResultsManagementsController < ApplicationController
  def index
    @term = Term.current_term
    @terms = Term.find(:all, :order => "start_at")
    @results = []
    
    if params[:id]
      term_id = params[:id]
      logger.info "term id=#{term_id}}"

      term = Term.find(term_id)
      @term = term
      term_start_yyyymm = term.start_at.strftime("%Y%m")
      term_end_yyyymm = term.end_at.strftime("%Y%m")
      @budgets = Budget.find_all_by_term_id(term_id)
      @expenses = Expense.where("acquired_at_ym BETWEEN ? AND ?", term_start_yyyymm, term_end_yyyymm).group(:acquired_at_ym).sum(:price)
      #TODO
      @budgets.each do |b|
        r = {}
        r[:item_of_expenditure] = I18n.t('activerecord.models.budget') 
        r[:item_of_expenditure] += "(" + b.note + ")" unless b.note.empty?
        r[:budget] = b.amount
        r[:created_at] = b.created_at.strftime("%Y%m%d")
        r[:type] = 1
        @results << r
      end
      @expenses.each do |k, v|
        r = {}
        r[:item_of_expenditure] = I18n.t('activerecord.attributes.budget_and_results_managements.expense_label', {:yyyy=>k.to_s.slice(0, 4), :mm=>k.to_s.slice(4, 2)})
        r[:expense] = v
        r[:created_at] = "#{k}99"
        r[:type] = 2
        @results << r
      end

      #pp @results
      remain_amount = 0
      amount = 0
      expense = 0
      @results.sort!{|a, b| a[:created_at] <=> b[:created_at]}
      @results.each do |r|
        if r[:type] == 1
          remain_amount += r[:budget] if r[:budget]
          amount += r[:budget] if r[:budget]
        else
          remain_amount -= r[:expense]
          expense += r[:expense]
        end
        r[:remain_amount] = remain_amount
        r[:digestibility] = (amount == 0)?(0):((Float(expense) / Float(amount)) * 100)
      end
    end
  end
end
