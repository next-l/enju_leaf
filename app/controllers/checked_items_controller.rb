class CheckedItemsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_basket

  # GET /checked_items
  # GET /checked_items.xml
  def index
    if @basket
      @checked_items = @basket.checked_items
      @checked_item = @basket.checked_items.new
    else
      access_denied
      return
    end

    if params[:mode] == 'list'
      render :partial => 'list'
      return
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @checked_items }
    end
  end

  # GET /checked_items/1
  # GET /checked_items/1.xml
  def show
    if @basket
      @checked_item = @basket.checked_items.find(params[:id])
    else
      access_denied
      return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @checked_item }
    end
  end

  # GET /checked_items/new
  # GET /checked_items/new.xml
  def new
    if @basket
      @checked_item = @basket.checked_items.new
    else
      access_denied
      return
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @checked_item }
    end
  end

  # GET /checked_items/1/edit
  def edit
    if @basket
      @checked_item = @basket.checked_items.find(params[:id])
    else
      access_denied
      return
    end
  end

  # POST /checked_items
  # POST /checked_items.xml
  def create
    if @basket
      @checked_item = CheckedItem.new(params[:checked_item])
      @checked_item.basket = @basket
    else
      access_denied
      return
    end

    flash[:message] = []
    item_identifier = @checked_item.item_identifier.to_s.strip
    unless item_identifier.blank?
      #item = Item.first(:conditions => {:item_identifier => item_identifier})
      item = Item.find_by_sql(['SELECT * FROM items WHERE item_identifier = ? LIMIT 1', item_identifier]).first
    end

    @checked_item.item = item unless item.blank?

    respond_to do |format|
      if @checked_item.save
        if @checked_item.item.reserved?
          if @checked_item.item.manifestation.is_reserved_by(@basket.user)
            reserve = Reserve.first(:conditions => {:user_id => @basket.user.id, :manifestation_id => @checked_item.item.manifestation.id})
            reserve.destroy
          end
        end

        if @checked_item.item.include_supplements
          flash[:message] << t('item.this_item_include_supplement')
        end
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.checked_item'))

        if params[:mode] == 'list'
          redirect_to(user_basket_checked_items_url(@basket.user.username, @basket, :mode => 'list'))
          return
        else
          flash[:message] << @checked_item.errors["base"]
          format.html { redirect_to(user_basket_checked_items_url(@basket.user.username, @basket)) }
          format.xml  { render :xml => @checked_item, :status => :created, :location => @checked_item }
        end
      else
        flash[:message] << @checked_item.errors["base"]
        if params[:mode] == 'list'
          #format.html { render :action => "new" }
          #format.xml  { render :xml => @checked_item.errors, :status => :unprocessable_entity }
          redirect_to(user_basket_checked_items_url(@basket.user.username, @basket, :mode => 'list'))
          return
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @checked_item.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /checked_items/1
  # PUT /checked_items/1.xml
  def update
    if @basket
      @checked_item = @basket.checked_items.find(params[:id])
    else
      access_denied
      return
    end

    respond_to do |format|
      if @checked_item.update_attributes(params[:checked_item])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.checked_item'))
        format.html { redirect_to(@checked_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @checked_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /checked_items/1
  # DELETE /checked_items/1.xml
  def destroy
    if @basket
      @checked_item = @basket.checked_items.find(params[:id])
    else
      access_denied
      return
    end
    @checked_item.destroy

    respond_to do |format|
      format.html { redirect_to(user_basket_checked_items_url(@checked_item.basket.user.username, @checked_item.basket)) }
      format.xml  { head :ok }
    end
  end

  private
  def validate_checked_item
  end
end
