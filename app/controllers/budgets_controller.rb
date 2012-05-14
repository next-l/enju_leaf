class BudgetsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def index
    @budgets = Budget.find(:all, :order => "library_id, term_id DESC, budget_type_id")
  end

  def new
    prepare_options
    @budget = Budget.new
  end

  def create
    @budget = Budget.new(params[:budget])

    respond_to do |format|
      if @budget.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.budget'))
        format.html { redirect_to(@budget) }
        format.json { render :json => @budget, :status => :created, :location => @budget }
      else
        prepare_options
        format.html { render :action => "new" }
        format.json { render :json => @budget.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    prepare_options
    @budget = Budget.find(params[:id])
  end

  def update
    @budget = Budget.find(params[:id])

    respond_to do |format|
      if @budget.update_attributes(params[:budget])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.budget'))
        format.html { redirect_to(@budget) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.json { render :json => @budget.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @budget = Budget.find(params[:id])
    @sum = Budget.sum(:amount, :conditions => {:library_id => @budget.library_id, :term_id => @budget.term_id})
    budget_ids = Budget.where(:library_id => @budget.library_id, :term_id => @budget.term_id).inject([]){|ids, budget| ids << budget.id}
    expense = Expense.sum(:price, :conditions => ["budget_id IN (?)", budget_ids])
    @balance = @sum - expense
  end

  def destroy
    @budget = Budget.find(params[:id])
    @budget.destroy

    respond_to do |format|
      format.html { redirect_to(budgets_url) }
      format.json { head :no_content }
    end
  end

private
  def prepare_options
    @libraries = Library.all
    @terms = Term.all
    @budget_types = BudgetType.all
  end
end
