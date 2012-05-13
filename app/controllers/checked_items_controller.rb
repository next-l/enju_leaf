class CheckedItemsController < ApplicationController
  include NotificationSound
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_basket

  # GET /checked_items
  # GET /checked_items.json
  def index
    unless @basket
      access_denied; return
    end
    unless @basket.user.patron
      redirect_to new_user_patron_url(@user); return
    end

    family_id = FamilyUser.find(:first, :conditions => ['user_id=?', @basket.user.id]).family_id rescue nil
    @family_users = Family.find(family_id).users.select{ |user| user != @basket.user } if family_id

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @basket.checked_items }
      format.js
    end
  end

  # GET /checked_items/1
  # GET /checked_items/1.json
  def show
    if @basket
      @checked_item = @basket.checked_items.find(params[:id])
    else
      access_denied; return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @checked_item }
    end
  end

  # GET /checked_items/new
  # GET /checked_items/new.json
  def new
    if @basket
      @checked_item = @basket.checked_items.new
    else
      access_denied; return
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @checked_item }
    end
  end

  # GET /checked_items/1/edit
  def edit
    if @basket
      @checked_item = @basket.checked_items.find(params[:id])
    else
      access_denied; return
    end
  end

  # POST /checked_items
  # POST /checked_items.json
  def create
    if @basket
      @checked_item = CheckedItem.new(params[:checked_item])
      @checked_item.basket = @basket
    else
      access_denied; return
    end

    messages = []
    flash[:message], flash[:sound] = '', ''
    item_identifier = @checked_item.item_identifier.to_s.strip
    item = Item.where(:item_identifier => item_identifier).first if item_identifier
    @checked_item.item = item if item

    respond_to do |format|
      if @checked_item.save
        flash[:warn] = t('checked_item.library_closed_today') if @checked_item.item.shelf.library.closed?(Time.zone.now)
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.checked_item'))
        messages << 'item.this_item_include_supplement' if @checked_item.item.include_supplements

        set_messages(messages)
        if params[:mode] == 'list'
          format.html { redirect_to(user_basket_checked_items_url(@basket.user, @basket, :mode => 'list')) }
          format.json { render :json => @checked_item, :status => :created, :location => @checked_item }
          format.js   { redirect_to(user_basket_checked_items_url(@basket.user, @basket, :format => :js)) }
        else
          format.html { redirect_to(user_basket_checked_items_url(@basket.user, @basket)) }
          format.json { render :json => @checked_item, :status => :created, :location => @checked_item }
        end
      else
        set_messages(messages)
        if params[:mode] == 'list'
          format.html { redirect_to(user_basket_checked_items_url(@basket.user, @basket, :mode => 'list')) }
          format.json { render :json => @checked_item, :status => :created, :location => @checked_item }
          format.js   { redirect_to(user_basket_checked_items_url(@basket.user, @basket, :format => :js)) }
        else
          format.html { render :action => "new" }
          format.json { render :json => @checked_item.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /checked_items/1
  # PUT /checked_items/1.json
  def update
    if @basket
      @checked_item = @basket.checked_items.find(params[:id])
    else
      access_denied; return
    end

    respond_to do |format|
      if @checked_item.update_attributes(params[:checked_item])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.checked_item'))
        format.html { redirect_to(@checked_item) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @checked_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /checked_items/1
  # DELETE /checked_items/1.json
  def destroy
    if @basket
      @checked_item = @basket.checked_items.find(params[:id])
    else
      access_denied; return
    end
    @checked_item.destroy

    respond_to do |format|
      format.html { redirect_to(user_basket_checked_items_url(@checked_item.basket.user, @checked_item.basket)) }
      format.json { head :no_content }
    end
  end

  private
  def set_messages(messages)
    @checked_item.errors[:base].each do |error|
      messages << error
    end
    messages.each do |message|
      return_message, return_sound = error_message_and_sound(message)
      flash[:message] << return_message + '<br />' if return_message
      flash[:sound] = return_sound if return_sound
    end
  end
end
