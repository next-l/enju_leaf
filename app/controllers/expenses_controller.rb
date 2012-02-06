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
end
