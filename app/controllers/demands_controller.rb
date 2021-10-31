class DemandsController < ApplicationController
  before_action :set_demand, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /demands
  # GET /demands.json
  def index
    @demands = Demand.order('id DESC').page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @demands }
    end
  end

  # GET /demands/1
  # GET /demands/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @demand }
      format.text
    end
  end

  # GET /demands/new
  # GET /demands/new.json
  def new
    @demand = Demand.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @demand }
    end
  end

  # GET /demands/1/edit
  def edit
  end

  # POST /demands
  # POST /demands.json
  def create
    @demand = Demand.new(demand_params)

    respond_to do |format|
      if @demand.save
        format.html { redirect_to @demand, notice: t('controller.successfully_created', model: t('activerecord.models.demand')) }
        format.json { render json: @demand, status: :created, location: @demand }
      else
        format.html { render action: "new" }
        format.json { render json: @demand.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /demands/1
  # PUT /demands/1.json
  def update
    respond_to do |format|
      if @demand.update(demand_params)
        format.html { redirect_to @demand, notice: t('controller.successfully_updated', model: t('activerecord.models.demand')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @demand.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /demands/1
  # DELETE /demands/1.json
  def destroy
    @demand.destroy

    respond_to do |format|
      format.html { redirect_to demands_url }
      format.json { head :no_content }
    end
  end

  private

  def set_demand
    @demand = Demand.find(params[:id])
    authorize @demand
  end

  def check_policy
    authorize Demand
  end

  def demand_params
    params.fetch(:demand, {}).permit()
  end
end
