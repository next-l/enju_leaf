class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :set_order_list
  before_action :set_purchase_request

  # GET /orders
  # GET /orders.json
  def index
    case
    when @order_list
      @orders = @order_list.orders.page(params[:page])
    else
      @orders = Order.page(params[:page])
    end
    @count = {}
    @count[:query_result] = @orders.size

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orders }
      format.rss
      format.atom
      format.text
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.json
  def new
    @order_lists = OrderList.not_ordered
    if @order_lists.blank?
      flash[:notice] = t('order.create_order_list')
      redirect_to new_order_list_url
      return
    end
    unless @purchase_request
      flash[:notice] = t('order.specify_purchase_request')
      redirect_to purchase_requests_url
      return
    end
    @order = Order.new(params[:order])
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
    @order_lists = OrderList.not_ordered
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        flash[:notice] = t('controller.successfully_created', model: t('activerecord.models.order'))
        if @purchase_request
          format.html { redirect_to purchase_request_order_url(@order.purchase_request, @order) }
          format.json { render json: @order, status: :created, location: @order }
        else
          format.html { redirect_to(@order) }
          format.json { render json: @order, status: :created, location: @order }
        end
      else
        @order_lists = OrderList.not_ordered
        format.html { render action: "new" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /orders/1
  # PUT /orders/1.json
  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update(order_params)
        flash[:notice] = t('controller.successfully_updated', model: t('activerecord.models.order'))
        if @purchase_request
          format.html { redirect_to purchase_request_order_url(@order.purchase_request, @order) }
          format.json { head :no_content }
        else
          format.html { redirect_to(@order) }
          format.json { head :no_content }
        end
      else
        @order_lists = OrderList.not_ordered
        format.html { render action: "edit" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order = Order.find(params[:id])

    @order.destroy

    respond_to do |format|
      if @order_list
        format.html { redirect_to purchase_requests_url(order_list: @order_list.id) }
        format.json { head :no_content }
      else
        format.html { redirect_to orders_url }
        format.json { head :no_content }
      end
    end
  end

  private
  def set_order
    @order = Order.find(params[:id])
    authorize @order
  end

  def set_order_list
    @order_list = OrderList.find_by(id: params[:order_list_id])
    authorize @order_list if @order_list
  end

  def set_purchase_request
    @purchase_request = PurchaseRequest.find_by(id: params[:purchase_request_id])
    authorize @purchase_request if @purchase_request
  end

  def check_policy
    authorize Order
  end

  def order_params
    params.require(:order).permit(:order_list_id, :purchase_request_id)
  end
end
