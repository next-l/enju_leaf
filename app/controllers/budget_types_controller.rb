class BudgetTypesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def index
    @budget_types = BudgetType.all
  end

  def new
    @budget_type = BudgetType.new
  end

  def create
    @budget_type = BudgetType.new(params[:budget_type])

    respond_to do |format|
      if @budget_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.budget_type'))
        format.html { redirect_to(@budget_type) }
        format.json { render :json => @budget_type, :status => :created, :location => @budget_type }
      else
        format.html { render :action => "new" }
        format.json { render :json => @budget_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @budget_type = BudgetType.find(params[:id])
  end

  def update
    @budget_type = BudgetType.find(params[:id])

    respond_to do |format|
      if @budget_type.update_attributes(params[:budget_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.budget_type'))
        format.html { redirect_to(@budget_type) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @budget_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @budget_type = BudgetType.find(params[:id])
  end

  def destroy
    @budget_type = BudgetType.find(params[:id])
    respond_to do |format|
      if @budget_type.budgets.empty?
        @budget_type.destroy
        format.html { redirect_to(budget_types_url) }
        format.json { head :no_content }
      else
        format.html { render :action => :index }
        format.json { render :json => @budget_type.errors, :status => :unprocessable_entity }
      end
    end
  end

end
