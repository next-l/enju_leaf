class BudgetAndResultsManagementsController < ApplicationController
  def show
    term_yyyymm01 = nil
    unless params[:id]
      access_denied; return
    end
    begin 
      term_yyyymm01 = Date.strptime(params[:id], "%Y%m")
    rescue ArgumentError 
      access_denied; return
    end

    term_start_yyyymm = term_yyyymm01.strftime("%Y%m")
    term_end_yyyymm = term_yyyymm01.end_of_month.strftime("%Y%m")

    @expenses = Expense.where("acquired_at_ym BETWEEN ? AND ?", term_start_yyyymm, term_end_yyyymm).order(:acquired_at_ym)

  end

  def index
    @term = Term.current_term
    @terms = Term.find(:all, :order => "start_at")
    @results = []
    @budget_sum = nil
    @expense_sum = nil
    
    if params[:id]
      term_id = params[:id]
      logger.info "term id=#{term_id}}"

      @budget_sum = 0
      @expense_sum = 0
 
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
        @budget_sum = @budget_sum +  b.amount
      end
      @expenses.each do |k, v|
        r = {}
        r[:item_of_expenditure] = I18n.t('activerecord.attributes.budget_and_results_managements.expense_label', {:yyyy=>k.to_s.slice(0, 4), :mm=>k.to_s.slice(4, 2)})
        r[:expense] = v
        r[:created_at] = "#{k}99"
        r[:type] = 2
        r[:ym] = k.to_s.slice(0, 6)
        @results << r
        @expense_sum = @expense_sum + v
      end

      @digestibility_sum = (@budget_sum == 0)?(0):((Float(@expense_sum) / Float(@budget_sum)) * 100)

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

      #
      if params[:output_tsv]
        #data = Manifestation.get_manifestation_list_tsv(manifestations_for_output, current_user)
        data = String.new
        data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"

        columns = [
          [:id, 'activerecord.attributes.budget_and_results_managements.id'],
          [:item_of_expenditure, 'activerecord.attributes.budget_and_results_managements.item_of_expenditure'],
          [:expense, 'activerecord.attributes.budget_and_results_managements.expense'],
          [:budget, 'activerecord.attributes.budget_and_results_managements.budget'],
          [:amount, 'activerecord.attributes.budget_and_results_managements.remain_amount'],
          [:digestibility, 'activerecord.attributes.budget_and_results_managements.digestibility']
        ]

        # title column
        row = columns.map{|column| I18n.t(column[1])}
        data << '"' + row.join("\"\t\"") +"\"\n"

        #
        cnt = 1
        @results.each do |r|
          row = []
          columns.each do |column|
            case column[0]
            when :id
              row << cnt.to_s
            when :item_of_expenditure
              row << r[:item_of_expenditure]
            when :expense
              row << r[:expense]
            when :budget
              row << r[:budget]
            when :amount
              row << r[:remain_amount]
            when :digestibility
              row << r[:digestibility]
            end
          end
          data << '"' + row.join("\"\t\"") +"\"\n"
        end

        send_data data, :filename => "budget_and_results.tsv"
        return 
      end
    end
  end
end
