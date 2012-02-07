class ExpensesController < ApplicationController
  def index
    @expenses = Expense.all
  end

  def show
    @expense = Expense.find(params[:id])
  end

  def edit
    @expense = Expense.find(params[:id])
    @budgets = Budget.all
  end

  def update
    @expense = Expense.find(params[:id])

    respond_to do |format|
      if @expense.update_attributes(params[:expense])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.expense'))
        format.html { redirect_to(@expense) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  def export_report
    @libraries = Library.all
    @bookstores = Bookstore.all
    @budgets = Budget.all
    @selected_budget = @budgets.map(&:id)
    @selected_library = @libraries.map(&:id)
    @selected_bookstore = @bookstores.map(&:id)
    @items_size = Expense.count(:all)
    @page = (@items_size / 36).to_f.ceil
  end

  def download_file
    budgets = params[:budget]
    libraries = params[:library]
    bookstores = params[:bookstore]
    term_from = parse_term(params[:term_from])
    term_to = parse_term(params[:term_to])
    if term_to.nil? && term_from
      expenses = Expense.joins(:item).where(["expenses.budget_id IN (?) AND items.shelf_id IN (?) AND items.bookstore_id IN (?) AND expenses.created_at >= ?", budgets, Shelf.where(["library_id IN (?)", libraries]).map(&:id), bookstores, term_from])
    elsif term_from.nil? && term_to
      expenses = Expense.joins(:item).where(["expenses.budget_id IN (?) AND items.shelf_id IN (?) AND items.bookstore_id IN (?) AND expenses.created_at <= ?", budgets, Shelf.where(["library_id IN (?)", libraries]).map(&:id), bookstores, term_to])
    elsif term_to && term_from
      expenses = Expense.joins(:item).where(["expenses.budget_id IN (?) AND items.shelf_id IN (?) AND items.bookstore_id IN (?) AND expenses.created_at >= ? AND expenses.created_at <= ?", budgets, Shelf.where(["library_id IN (?)", libraries]).map(&:id), bookstores, term_from, term_to])
    else
      expenses = Expense.joins(:item).where(["expenses.budget_id IN (?) AND items.shelf_id IN (?) AND items.bookstore_id IN (?)", budgets, Shelf.where(["library_id IN (?)", libraries]).map(&:id), bookstores])
    end
    if params[:pdf]
      file = Expense.export_pdf(expenses)
      send_file file
    elsif params[:tsv]
      file = Expense.export_tsv(expenses)
      send_file file
    end
    rescue Exception => e
      logger.error "Failed to download file: #{e}"
      redirect_to :export_report
  end

  def get_list_size
    return nil unless request.xhr?
    budgets = params[:budgets]
    libraries = params[:libraries]
    bookstores = params[:bookstores]
    term_from = parse_term(params[:term_from])
    term_to = parse_term(params[:term_to])
    error = false
    list_size = 0

    logger.error "term from: #{term_from}"
    logger.error "term to: #{term_to}"

    # check checkbox
    error = true if libraries.blank? || budgets.blank? || bookstores.blank?

    # list_size
    unless error
      begin
        if term_to.nil? && term_from
          expenses = Expense.joins(:item).where(["expenses.budget_id IN (?) AND items.shelf_id IN (?) AND items.bookstore_id IN (?) AND expenses.created_at >= ?", budgets, Shelf.where(["library_id IN (?)", libraries]).map(&:id), bookstores, term_from])
        elsif term_from.nil? && term_to
          expenses = Expense.joins(:item).where(["expenses.budget_id IN (?) AND items.shelf_id IN (?) AND items.bookstore_id IN (?) AND expenses.created_at <= ?", budgets, Shelf.where(["library_id IN (?)", libraries]).map(&:id), bookstores, term_to])
        elsif term_to && term_from
          expenses = Expense.joins(:item).where(["expenses.budget_id IN (?) AND items.shelf_id IN (?) AND items.bookstore_id IN (?) AND expenses.created_at >= ? AND expenses.created_at <= ?", budgets, Shelf.where(["library_id IN (?)", libraries]).map(&:id), bookstores, term_from, term_to])
        else
          expenses = Expense.joins(:item).where(["expenses.budget_id IN (?) AND items.shelf_id IN (?) AND items.bookstore_id IN (?)", budgets, Shelf.where(["library_id IN (?)", libraries]).map(&:id), bookstores])
        end
        list_size = expenses.size
      rescue
        list_size = 0
      end
    end

    #page
    page = (list_size / 36).to_f.ceil
    page = 1 if page == 0 and !error

    render :json => {:success => 1, :list_size => list_size, :page => page}
  end

private
  def parse_term(term)
    return nil if term.blank?
    date = nil
    begin
      if term =~ /^\d{8}/
        date = Time.zone.parse("#{term}")
      elsif term =~ /^\d{6}/
        date = Time.zone.parse("#{term}01")  
      elsif term =~ /^\d{4}/
        date = Time.zone.parse("#{term}0101")
      end
    rescue 
      date = nil
    end
    return date
  end
end
