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
    @budget_types = BudgetType.all
    @item_types = [[t('item.general_item'), 1], [t('item.audio_item'), 2]]
    @selected_budget = @budgets.map(&:id)
    @selected_budget_type = @budget_types.map(&:id)
    @selected_library = @libraries.map(&:id)
    @selected_bookstore = @bookstores.map(&:id)
    @selected_item_type = @item_types.inject([]){|ids, type| ids << type[1]}
    @items_size = Expense.joins(:item).count(:all)
    @page = (@items_size / 36).to_f.ceil
  end

  def download_file
    budgets = params[:budget] || []
    all_budgets = eval(params[:all_budgets])
    no_budget = eval(params[:no_budget])
    budgets << nil if no_budget
    libraries = params[:librarie] || []
    all_libraries = eval(params[:all_libraries])
    no_library = eval(params[:no_library])
    bookstores = params[:bookstore] || []
    all_bookstores = eval(params[:all_bookstores])
    no_bookstore = eval(params[:no_bookstore])
    bookstores << nil if no_bookstore
    term_from = parse_term(params[:term_from])
    term_to = parse_term(params[:term_to])
    budget_types = params[:budget_type] || []
    all_budget_types = eval(params[:all_budget_types])
    no_budget_type = eval(params[:no_budget_type])
    budget_types << nil if no_budget_type
    item_types = params[:item_type] || []
    all_item_types = eval(params[:all_item_types])
    no_item_type = eval(params[:no_item_type])
    item_types << nil if no_item_type

    expenses = Expense.joins("left outer join budgets on budgets.id = expenses.budget_id").joins(:item => :manifestation)
    expenses = expenses.where(["expenses.budget_id IN (?)", budgets]) unless all_budgets
    unless all_libraries
      shelf_ids = Shelf.where(["library_id IN (?)", libraries]).map(&:id)
      shelf_ids << nil if no_library
      expenses = expenses.where(["items.shelf_id IN (?)", shelf_ids])
    end
    expenses = expenses.where(["items.bookstore_id IN (?)", bookstores]) unless all_bookstores
    expenses = expenses.where(["budgets.budget_type_id IN (?)", budget_types]) unless all_budget_types
    unless all_item_types
      # general item
      if item_types.include?("1") && !item_types.include?("2")
         type_ids = CarrierType.not_audio.map(&:id) 
      # audio item
      elsif !item_types.include?("1") && item_types.include?("2")
        type_ids = CarrierType.audio.map(&:id)
      end
      type_ids << nil if no_item_type
      expenses = expenses.where(["manifestations.carrier_type_id IN (?)", type_ids])
    end

    # term to
    expenses = expenses.where(["expenses.created_at <= ?", term_to]) if term_to
    # term from
    expenses = expenses.where(["expenses.created_at >= ?", term_from]) if term_from

    if expenses.blank?
      logger.error "No expenses matched"
      render :export_report      
    end    
    if params[:pdf]
      file = Expense.export_pdf(expenses)
      send_data file, :filename => "expense_list.pdf", :type => 'application/pdf', :disposition => 'attachment'
    elsif params[:tsv]
      file = Expense.export_tsv(expenses)
      send_file file
    end
    rescue Exception => e
      logger.error "Failed to download file: #{e}"
      render :export_report
  end

  def get_list_size
    return nil unless request.xhr?
    budgets = params[:budgets] || []
    all_budgets = eval(params[:all_budgets])
    no_budget = eval(params[:no_budget])
    budgets << nil if no_budget
    libraries = params[:libraries] || []
    all_libraries = eval(params[:all_libraries])
    no_library = eval(params[:no_library])
    bookstores = params[:bookstores] || []
    all_bookstores = eval(params[:all_bookstores])
    no_bookstore = eval(params[:no_bookstore])
    bookstores << nil if no_bookstore
    term_from = parse_term(params[:term_from])
    term_to = parse_term(params[:term_to])
    budget_types = params[:budget_types] || []
    all_budget_types = eval(params[:all_budget_types])
    no_budget_type = eval(params[:no_budget_type])
    budget_types << nil if no_budget_type
    item_types = params[:item_types] || []
    all_item_types = eval(params[:all_item_types])
    no_item_type = eval(params[:no_item_type])
    item_types << nil if no_item_type
    error = false
    list_size = 0

    # check checkbox
    error = true if libraries.blank? || budgets.blank? || bookstores.blank?

    # list_size
    unless error
      begin
        expenses = Expense.joins("left outer join budgets on budgets.id = expenses.budget_id").joins(:item => :manifestation)
        expenses = expenses.where(["expenses.budget_id IN (?)", budgets]) unless all_budgets
        unless all_libraries
          shelf_ids = Shelf.where(["library_id IN (?)", libraries]).map(&:id)
          shelf_ids << nil if no_library
          expenses = expenses.where(["items.shelf_id IN (?)", shelf_ids])
        end
        expenses = expenses.where(["items.bookstore_id IN (?)", bookstores]) unless all_bookstores
        expenses = expenses.where(["budgets.budget_type_id IN (?)", budget_types]) unless all_budget_types
        unless all_item_types
          # general item
          if item_types.include?("1") && !item_types.include?("2")
            type_ids = CarrierType.not_audio.map(&:id) 
          # audio item
          elsif !item_types.include?("1") && item_types.include?("2")
            type_ids = CarrierType.audio.map(&:id)
          end
          type_ids << nil if no_item_type
          expenses = expenses.where(["manifestations.carrier_type_id IN (?)", type_ids])
        end

        # term to
        expenses = expenses.where(["expenses.created_at <= ?", term_to]) if term_to
        # term from
        expenses = expenses.where(["expenses.created_at >= ?", term_from]) if term_from

        list_size = expenses.size
      rescue Exception => e
        logger.error "Failed to get list_size: #{e}"
        list_size = 1
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
