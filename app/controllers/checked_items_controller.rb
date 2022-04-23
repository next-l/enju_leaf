class CheckedItemsController < ApplicationController
  before_action :set_checked_item, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_basket, only: [:index, :new, :create, :update]

  # GET /checked_items
  # GET /checked_items.json
  def index
    if @basket
      @checked_items = @basket.checked_items.order('created_at DESC').page(params[:page])
    else
      @checked_items = CheckedItem.order('created_at DESC').page(params[:page])
    end
    @checked_item = CheckedItem.new

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  # GET /checked_items/1
  # GET /checked_items/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /checked_items/new
  def new
    unless @basket
      redirect_to new_basket_url
      return
    end
    @checked_item = CheckedItem.new
    @checked_items = @basket.checked_items
  end

  # GET /checked_items/1/edit
  def edit
  end

  # POST /checked_items
  # POST /checked_items.json
  def create
    unless @basket
      access_denied
      return
    end
    @checked_item = CheckedItem.new(checked_item_params)
    @checked_item.basket = @basket
    @checked_item.librarian = current_user

    flash[:message] = ''

    respond_to do |format|
      if @checked_item.save
        if @checked_item.item.include_supplements
          flash[:message] << t('item.this_item_include_supplement')
        end
        format.html { redirect_to(checked_items_url(basket_id: @basket.id), notice: t('controller.successfully_created', model: t('activerecord.models.checked_item'))) }
        format.json { render json: @checked_item, status: :created, location: @checked_item }
        format.js { redirect_to(checked_items_url(basket_id: @basket.id, format: :js)) }
      else
        @checked_items = @basket.checked_items.order('created_at DESC').page(1)
        format.html { render action: "index" }
        format.json { render json: @checked_item.errors, status: :unprocessable_entity }
        format.js { render action: "index" }
      end
    end
  end

  # PUT /checked_items/1
  # PUT /checked_items/1.json
  def update
    if @basket
      @checked_item = @basket.checked_items.find(params[:id])
    else
      access_denied
      return
    end

    respond_to do |format|
      if @checked_item.update(checked_item_params)
        format.html { redirect_to checked_item_url(@checked_item), notice: t('controller.successfully_updated', model: t('activerecord.models.checked_item')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @checked_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checked_items/1
  # DELETE /checked_items/1.json
  def destroy
    @checked_item.destroy

    respond_to do |format|
      format.html { redirect_to checked_items_url(basket_id: @checked_item.basket_id) }
      format.json { head :no_content }
    end
  end

  private

  def set_checked_item
    @checked_item = CheckedItem.find(params[:id])
    authorize @checked_item
  end

  def check_policy
    authorize CheckedItem
  end

  def checked_item_params
    params.fetch(:checked_item, {}).permit(
      :item_identifier, :ignore_restriction, :due_date_string, :lock_version
    )
  end
end
