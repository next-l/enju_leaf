class BasketsController < ApplicationController
  load_and_authorize_resource
  cache_sweeper :circulation_sweeper, :only => [:create, :update, :destroy]

  # GET /baskets
  # GET /baskets.json
  def index
    if current_user.has_role?('Librarian')
     @baskets = Basket.page(params[:page])
    else
      redirect_to new_basket_url
      return
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @baskets }
    end
  end

  # GET /baskets/1
  # GET /baskets/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @basket }
    end
  end

  # GET /baskets/new
  # GET /baskets/new.json
  def new
    @basket = Basket.new
    @basket.user_number = params[:user_number]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @basket }
    end
  end

  # GET /baskets/1/edit
  def edit
  end

  # POST /baskets
  # POST /baskets.json
  def create
    @basket = Basket.new
    @user = User.where(:user_number => params[:basket][:user_number]).first rescue nil
    if @user
      if @user.user_number?
        @basket.user = @user
      end
    end

    respond_to do |format|
      if @basket.save
        format.html { redirect_to new_basket_checked_item_url(@basket), :notice => t('controller.successfully_created', :model => t('activerecord.models.basket')) }
        format.json { render :json => @basket, :status => :created, :location => @basket }
      else
        format.html { render :action => "new" }
        format.json { render :json => @basket.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /baskets/1
  # PUT /baskets/1.json
  def update
    librarian = current_user
    begin
      unless @basket.basket_checkout(librarian)
        redirect_to new_basket_checked_item_url(@basket)
        return
      end
    rescue ActiveRecord::RecordInvalid
      flash[:message] = t('checked_item.already_checked_out_try_again')
      @basket.checked_items.delete_all
      redirect_to new_basket_checked_item_url(@basket)
      return
    end

    #@checkout_count = @basket.user.checkouts.count
    respond_to do |format|
      #if @basket.update_attributes({})
      if @basket.save(:validate => false)
        # 貸出完了時
        format.html { redirect_to user_checkouts_url(@basket.user), :notice => t('basket.checkout_completed') }
        format.json { head :no_content }
      else
        format.html { redirect_to basket_checked_items_url(@basket) }
        format.json { render :json => @basket.errors, :status => :unprocessable_entity }
      end
    end

  end

  # DELETE /baskets/1
  # DELETE /baskets/1.json
  def destroy
    @basket.destroy

    respond_to do |format|
      #format.html { redirect_to(user_baskets_url(@user)) }
      format.html { redirect_to user_checkouts_url(@basket.user) }
      format.json { head :no_content }
    end
  end
end
