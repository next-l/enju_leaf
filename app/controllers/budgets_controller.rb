class BudgetsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def index
    @budgets = Budget.all
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
        format.xml  { render :xml => @budget, :status => :created, :location => @budget }
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @budget.errors, :status => :unprocessable_entity }
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
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @budget.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @budget = Budget.find(params[:id])
  end
  def destroy
    @budget = Budget.find(params[:id])
    @budget.destroy

    respond_to do |format|
      format.html { redirect_to(budgets_url) }
      format.xml  { head :ok }
    end
  end

private
  def prepare_options
    @libraries = Library.all
    @terms = Term.all
  end
end
