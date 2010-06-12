class OrderListsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_bookstore

  # GET /order_lists
  # GET /order_lists.xml
  def index
    if @bookstore
      @order_lists = @bookstore.order_lists.paginate(:all, :page => params[:page])
    else
      @order_lists = OrderList.paginate(:all, :page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @order_lists }
      format.rss  { render :layout => false }
      format.atom
    end
  end

  # GET /order_lists/1
  # GET /order_lists/1.xml
  def show
    @order_list = OrderList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @order_list }
    end
  end

  # GET /order_lists/new
  # GET /order_lists/new.xml
  def new
    @order_list = OrderList.new
    @bookstores = Bookstore.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @order_list }
    end
  end

  # GET /order_lists/1/edit
  def edit
    @order_list = OrderList.find(params[:id])
    @bookstores = Bookstore.all
  end

  # POST /order_lists
  # POST /order_lists.xml
  def create
    @order_list = OrderList.new(params[:order_list])
    @order_list.user = current_user

    respond_to do |format|
      if @order_list.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.order_list'))
        format.html { redirect_to(@order_list) }
        format.xml  { render :xml => @order_list, :status => :created, :location => @order_list }
      else
        @bookstores = Bookstore.all
        format.html { render :action => "new" }
        format.xml  { render :xml => @order_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /order_lists/1
  # PUT /order_lists/1.xml
  def update
    @order_list = OrderList.find(params[:id])

    respond_to do |format|
      if @order_list.update_attributes(params[:order_list])
        @order_list.aasm_order! if params[:mode] == 'order'
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.order_list'))
        format.html { redirect_to(@order_list) }
        format.xml  { head :ok }
      else
        @bookstores = Bookstore.all
        format.html { render :action => "edit" }
        format.xml  { render :xml => @order_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /order_lists/1
  # DELETE /order_lists/1.xml
  def destroy
    @order_list = OrderList.find(params[:id])
    @order_list.destroy

    respond_to do |format|
      format.html { redirect_to(order_lists_url) }
      format.xml  { head :ok }
    end
  end
end
