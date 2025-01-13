class CheckinsController < ApplicationController
  before_action :set_checkin, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_basket, only: [:index, :create]

  # GET /checkins
  # GET /checkins.json
  def index
    if @basket
      @checkins = @basket.checkins.page(params[:page])
    else
      @checkins = Checkin.page(params[:page])
    end
    @checkin = Checkin.new

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  # GET /checkins/1
  # GET /checkins/1.json
  def show
    # @checkin = Checkin.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /checkins/new
  def new
    flash[:message] = nil
    if flash[:checkin_basket_id]
      @basket = Basket.find(flash[:checkin_basket_id])
    else
      @basket = Basket.new
      @basket.user = current_user
      @basket.save!
    end
    @checkin = Checkin.new
    @checkins = Kaminari::paginate_array([]).page(1)
    flash[:checkin_basket_id] = @basket.id
  end

  # GET /checkins/1/edit
  def edit
    # @checkin = Checkin.find(params[:id])
  end

  # POST /checkins
  # POST /checkins.json
  def create
    unless @basket
      access_denied
      return
    end
    @checkin = Checkin.new(checkin_params)
    @checkin.basket = @basket
    @checkin.librarian = current_user

    flash[:message] = ''

    respond_to do |format|
      if @checkin.save
        message = @checkin.item_checkin(current_user)
        if @checkin.checkout
          flash[:message] << t('checkin.successfully_checked_in')
        else
          flash[:message] << t('checkin.not_checked_out')
        end
        flash[:message] << message if message
        format.html { redirect_to checkins_url(basket_id: @checkin.basket_id) }
        format.json { render json: {result: @checkin, messages: flash[:message]}, status: :created, location: @checkin }
        format.js { redirect_to checkins_url(basket_id: @basket.id, format: :js) }
      else
        @checkins = @basket.checkins.page(1)
        format.html { render action: "new" }
        format.json { render json: {messages: @checkin.errors}, status: :unprocessable_entity }
        format.js { render action: "index" }
      end
    end
  end

  # PUT /checkins/1
  # PUT /checkins/1.json
  def update
    @checkin.assign_attributes(checkin_params)
    @checkin.librarian = current_user

    respond_to do |format|
      if @checkin.save
        format.html { redirect_to @checkin, notice: t('controller.successfully_updated', model: t('activerecord.models.checkin')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @checkin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checkins/1
  # DELETE /checkins/1.json
  def destroy
    # @checkin = Checkin.find(params[:id])
    @checkin.destroy

    respond_to do |format|
      format.html { redirect_to checkins_url }
      format.json { head :no_content }
    end
  end

  private

  def set_checkin
    @checkin = Checkin.find(params[:id])
    authorize @checkin
  end

  def check_policy
    authorize Checkin
  end

  def checkin_params
    params.require(:checkin).permit(:item_identifier)
  end
end
