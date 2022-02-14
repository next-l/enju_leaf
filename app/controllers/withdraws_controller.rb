class WithdrawsController < ApplicationController
  before_action :set_withdraw, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_basket, only: [:index, :create]

  # GET /withdraws
  # GET /withdraws.json
  def index
    if request.format.text?
      @withdraws = Withdraw.order('withdraws.created_at DESC').page(params[:page]).per(65534)
    else
      if params[:withdraw]
        @query = params[:withdraw][:item_identifier].to_s.strip
        item = Item.find_by(item_identifier: @query) if @query.present?
      end

      if item
        @withdraws = Withdraw.order('withdraws.created_at DESC').where(item_id: item.id).page(params[:page])
      else
        if @basket
          @withdraws = @basket.withdraws.order('withdraws.created_at DESC').page(params[:page])
        else
          @withdraws = Withdraw.order('withdraws.created_at DESC').page(params[:page])
        end
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @withdraws }
      format.js { @withdraw = Withdraw.new }
      format.text
    end
  end

  # GET /withdraws/1
  # GET /withdraws/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @withdraw }
    end
  end

  # GET /new
  # GET /new.json
  def new
    @basket = Basket.new
    @basket.user = current_user
    @basket.save!
    @withdraw = Withdraw.new
    authorize @withdraw, :new?
    @withdraws = []

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @withdraw }
    end
  end

  # GET /withdraws/new
  # GET /withdraws/1/edit
  def edit
  end

  # POST /withdraws
  # POST /withdraws.json
  def create
    unless @basket
      access_denied
      return
    end
    @withdraw = Withdraw.new(withdraw_params)
    @withdraw.basket = @basket
    @withdraw.librarian = current_user

    flash[:message] = ''
    if @withdraw.item_identifier.blank?
      flash[:message] << t('withdraw.enter_item_identifier') if @withdraw.item_identifier.blank?
    else
      item = Item.find_by(item_identifier: @withdraw.item_identifier.to_s.strip)
    end
    @withdraw.item = item

    respond_to do |format|
      if @withdraw.save
        flash[:message] << t('withdraw.successfully_withdrawn', model: t('activerecord.models.withdraw'))
        format.html { redirect_to withdraws_url(basket_id: @basket.id) }
        format.json { render json: @withdraw, status: :created, location: @withdraw }
        format.js { redirect_to withdraws_url(basket_id: @basket.id, format: :js) }
      else
        @withdraws = @basket.withdraws.page(params[:page])
        format.html { render action: "index" }
        format.json { render json: @withdraw.errors, status: :unprocessable_entity }
        format.js { render action: "index" }
      end
    end
  end

  # PUT /withdraws/1
  # PUT /withdraws/1.json
  def update
    respond_to do |format|
      if @withdraw.update(withdraw_params)
        format.html { redirect_to @withdraw, notice: t('controller.successfully_updated', model: t('activerecord.models.withdraw')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @withdraw.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /withdraws/1
  # DELETE /withdraws/1.json
  def destroy
    @withdraw.destroy

    respond_to do |format|
      format.html { redirect_to withdraws_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.withdraw')) }
      format.json { head :no_content }
    end
  end

  private

  def set_withdraw
    @withdraw = Withdraw.find(params[:id])
    authorize @withdraw
  end

  def check_policy
    authorize Withdraw
  end

  def withdraw_params
    params.require(:withdraw).permit(:item_identifier, :librarian_id, :item_id)
  end
end
