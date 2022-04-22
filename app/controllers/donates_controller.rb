class DonatesController < ApplicationController
  before_action :set_donate, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /donates
  # GET /donates.json
  def index
    @donates = Donate.order('id DESC').page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /donates/1
  # GET /donates/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /donates/new
  def new
    @donate = Donate.new
  end

  # GET /donates/1/edit
  def edit
  end

  # POST /donates
  # POST /donates.json
  def create
    @donate = Donate.new(donate_params)

    respond_to do |format|
      if @donate.save
        format.html { redirect_to @donate, notice: t('controller.successfully_created', model: t('activerecord.models.donate')) }
        format.json { render json: @donate, status: :created, location: @donate }
      else
        format.html { render action: "new" }
        format.json { render json: @donate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /donates/1
  # PUT /donates/1.json
  def update
    respond_to do |format|
      if @donate.update(donate_params)
        format.html { redirect_to @donate, notice: t('controller.successfully_updated', model: t('activerecord.models.donate')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @donate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /donates/1
  # DELETE /donates/1.json
  def destroy
    @donate.destroy

    respond_to do |format|
      format.html { redirect_to(donates_url) }
      format.json { head :no_content }
    end
  end

  private
  def set_donate
    @donate = Donate.find(params[:id])
    authorize @donate
  end

  def check_policy
    authorize Donate
  end

  def donate_params
    params.require(:donate).permit(:agent_id, :item_id)
  end
end
