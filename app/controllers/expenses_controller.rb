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
        format.json { head :no_content }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.json { render :json => @expense.errors, :status => :unprocessable_entity }
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
    @no_budget = @no_library = @no_bookstore = @no_budget_type = @no_item_type = true

    @items_size = Expense.joins(:item).count(:all)
    @page = (@items_size / 36).to_f.ceil
  end

  def download_file
    @libraries = Library.all
    @bookstores = Bookstore.all
    @budgets = Budget.all
    @budget_types = BudgetType.all
    @item_types = [[t('item.general_item'), 1], [t('item.audio_item'), 2]]

    # budgets 
    @selected_budget = params[:budget] || []
    budgets = @selected_budget.clone
    all_budgets = eval(params[:all_budgets]) if params[:all_budgets]
    @selected_budget = @budgets.map(&:id) if all_budgets
    @no_budget = eval(params[:no_budget]) if params[:no_budget]
    # libraries
    @selected_library =params[:library] || []
    libraries = @selected_library.clone
    all_libraries = eval(params[:all_libraries]) if params[:all_libraries]
    @selected_library = @libraries.map(&:id) if all_libraries
    @no_library = eval(params[:no_library]) if params[:no_library] 
    # bookstores
    @selected_bookstore = params[:bookstore] || []
    bookstores = @selected_bookstore.clone
    all_bookstores = eval(params[:all_bookstores]) if params[:all_bookstores]
    @selected_bookstore = @bookstores.map(&:id) if all_bookstores
    @no_bookstore = eval(params[:no_bookstore]) if params[:no_bookstore]
    # budget_types
    @selected_budget_type = params[:budget_type] || []
    budget_types = @selected_budget_type.clone
    all_budget_types = eval(params[:all_budget_types]) if params[:all_budget_types]
    @selected_budget_type = @budget_types.map(&:id) if all_budget_types
    @no_budget_type = eval(params[:no_budget_type]) if params[:no_budget_type]
    # item_types
    @selected_item_type = params[:item_type] || []
    item_types = @selected_item_type.clone
    @selected_item_type = @selected_item_type.inject([]){|ids, id| ids << id.to_i} if @selected_item_type
    all_item_types = eval(params[:all_item_types]) if params[:all_item_types]
    @selected_item_type = @item_types.inject([]){|ids, type| ids << type[1]} if all_item_types
    @no_item_type = eval(params[:no_item_type]) if params[:no_item_type]
    # term
    @term_from = parse_term(params[:term_from])
    @term_to = parse_term(params[:term_to])

    # checke checked
    error = false
    error = true if @selected_budget.blank? and @no_budget.blank?
    error = true if @selected_library.blank? and @no_library.blank?
    error = true if @selected_bookstore.blank? and @no_bookstore.blank?
    error = true if @selected_budget_type.blank? and @no_budget_type.blank?
    error = true if @selected_item_type.blank? and @no_item_type.blank?
    if error
      flash[:message] = t('item_list.no_list_condition') 
      @items_size = @page = 0
      render :export_report      
      return false
    end

    # all_expenses
    expenses = Expense.joins("left outer join budgets on budgets.id = expenses.budget_id").joins(:item => :manifestation)

    # budgets
    unless all_budgets
      unless @no_budget
        expenses = expenses.where(["expenses.budget_id IN (?)", budgets])
      else
        expenses = expenses.where(["expenses.budget_id IN (?)", budgets])
      end
    end

    # library
    unless all_libraries
      shelf_ids = Shelf.where(["library_id IN (?)", libraries]).map(&:id)
      unless @no_library
        expenses = expenses.where(["items.shelf_id IN (?)", shelf_ids])
      else
        expenses = expenses.where(["items.shelf_id IN (?) OR items.shelf_id IS NULL", shelf_ids])
      end
    end

    # bookstore
    unless all_bookstores
      unless @no_bookstore
        expenses = expenses.where(["items.bookstore_id IN (?)", bookstores])
      else
        expenses = expenses.where(["items.bookstore_id IN (?) OR items.bookstore_id IS NULL", bookstores])
      end
    end

    # budget_type
    unless all_budget_types
      unless @no_budget_type
        expenses = expenses.where(["budgets.budget_type_id IN (?)", budget_types])
      else
        expenses = expenses.where(["budgets.budget_type_id IN (?) OR budgets.budget_type_id IS NULL", budget_types])
      end
    end

    # item_typ
    unless all_item_types
      # general item
      if item_types.include?("1") && !item_types.include?("2")
         type_ids = CarrierType.not_audio.map(&:id) 
      # audio item
      elsif !item_types.include?("1") && item_types.include?("2")
        type_ids = CarrierType.audio.map(&:id)
      end
      unless @no_item_type
        expenses = expenses.where(["manifestations.carrier_type_id IN (?)", type_ids])
      else
        expenses = expenses.where(["manifestations.carrier_type_id IN (?) OR manifestations.carrier_type_id IS NULL", type_ids])
      end
    end

    # term to
    expenses = expenses.where(["expenses.created_at <= ?", @term_to]) if @term_to
    # term from
    expenses = expenses.where(["expenses.created_at >= ?", @term_from]) if @term_from

    # checked item_exit?
    if expenses.blank?
      flash[:message] = t('item_list.no_record') 
      @items_size = @page = 0
      logger.error "No expenses matched"
      render :export_report      
      return false
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
    # budgets
    budgets = params[:budgets] || []
    all_budgets = eval(params[:all_budgets]) if params[:all_budgets]
    no_budget = eval(params[:no_budget]) if params[:no_budget]
    # libraries
    libraries = params[:libraries] || []
    all_libraries = eval(params[:all_libraries]) if params[:all_libraries]
    no_library = eval(params[:no_library]) if params[:no_library]
    libraries << nil if no_library
    # bookstores
    bookstores = params[:bookstores] || []
    all_bookstores = eval(params[:all_bookstores]) if params[:all_bookstores]
    no_bookstore = eval(params[:no_bookstore]) if params[:no_bookstore]
    # budget_types
    budget_types = params[:budget_types] || []
    all_budget_types = eval(params[:all_budget_types]) if params[:all_budget_types]
    no_budget_type = eval(params[:no_budget_type]) if params[:no_budget_type]
    # item_types
    item_types = params[:item_types] || []
    all_item_types = eval(params[:all_item_types]) if params[:all_item_types]
    no_item_type = eval(params[:no_item_type]) if params[:no_item_type]
    # term
    term_from = parse_term(params[:term_from])
    term_to = parse_term(params[:term_to])

    error = false
    list_size = 0

    # check checkbox
    error = true if budgets.blank? and no_budget.blank?
    error = true if libraries.blank? and no_library.blank?
    error = true if bookstores.blank? and no_bookstore.blank?
    error = true if budget_types.blank? and no_budget_type.blank?
    error = true if item_types.blank? and no_item_type.blank?

    # list_size
    unless error
      begin
        # all
        expenses = Expense.joins("left outer join budgets on budgets.id = expenses.budget_id").joins(:item => :manifestation)

        # select budget
        unless all_budgets
          unless no_budget
            expenses = expenses.where(["expenses.budget_id IN (?)", budgets])
          else
            expenses = expenses.where(["expenses.budget_id IN (?) OR expenses.budget_id IS NULL", budgets])
          end
        end
        # select library
        unless all_libraries
          shelf_ids = Shelf.where(["library_id IN (?)", libraries]).map(&:id)
          unless no_library
            expenses = expenses.where(["items.shelf_id IN (?)", shelf_ids])
          else
            expenses = expenses.where(["items.shelf_id IN (?) OR items.shelf_id IS NULL", shelf_ids])
          end
        end
        # select bookstore
        unless all_bookstores
          unless no_bookstore
            expenses = expenses.where(["items.bookstore_id IN (?)", bookstores])
          else
            expenses = expenses.where(["items.bookstore_id IN (?) OR items.bookstore_id IS NULL", bookstores])
          end
        end
        # budget_type
        unless all_budget_types
          unless no_budget_type
            expenses = expenses.where(["budgets.budget_type_id IN (?)", budget_types])
          else
            expenses = expenses.where(["budgets.budget_type_id IN (?) OR budgets.budget_type_id IS NULL", budget_types])
          end
        end
        # item_type
        unless all_item_types
          # general item
          if item_types.include?("1") && !item_types.include?("2")
            type_ids = CarrierType.not_audio.map(&:id) 
          # audio item
          elsif !item_types.include?("1") && item_types.include?("2")
            type_ids = CarrierType.audio.map(&:id)
          end
          unless no_item_type
            expenses = expenses.where(["manifestations.carrier_type_id IN (?)", type_ids])
          else
            expenses = expenses.where(["manifestations.carrier_type_id IN (?) OR manifestations.carrier_type_id IS NULL", type_ids])
          end
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
