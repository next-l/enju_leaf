class CheckinsController < ApplicationController
  include NotificationSound

  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_user_if_nil
  helper_method :get_basket
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /checkins
  # GET /checkins.xml
  def index
    # かごがない場合、自動的に作成する
    get_basket
    unless @basket
      @basket = Basket.create!(:user => current_user)
      redirect_to user_basket_checkins_url(@basket.user, @basket)
      return
    end
    @checkins = @basket.checkins.order('checkins.created_at DESC').all
    @checkin = @basket.checkins.new

    unless @checkins.blank?
      if @checkins[0].checkout
        @checkout_user = @checkins[0].checkout.user
        family_id = FamilyUser.find(:first, :conditions => ['user_id=?', @checkout_user.id]).family_id rescue nil
        if family_id
          @family_users = Family.find(family_id).users
          @family_users.delete_if{|f_user| f_user == @checkout_user}
        end
        @reserve = Reserve.where(:item_id => @checkins[0].checkout.item.id, :state => 'retained').first if @checkins[0].checkout.item
      end
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @checkins.to_xml }
      format.js
    end
  end

  # GET /checkins/1
  # GET /checkins/1.xml
  def show
    #@checkin = Checkin.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @checkin.to_xml }
    end
  end

  # GET /checkins/new
  def new
    #@checkin = @basket.checkins.new
    redirect_to checkins_url
  end

  # GET /checkins/1;edit
  def edit
    #@checkin = Checkin.find(params[:id])
  end

  # POST /checkins
  # POST /checkins.xml
  def create
    get_basket
    unless @basket
      @basket = Basket.new(:user => current_user)
      @basket.save(:validate => false)
    end
    @checkin = @basket.checkins.new(params[:checkin])

    debugger

    messages = []
    flash[:message] = ''
    flash[:sound] = ''
    messages << 'checkin.enter_item_identifier' if @checkin.item_identifier.blank?
    item = Item.where(:item_identifier => @checkin.item_identifier.to_s.strip).first unless @checkin.item_identifier.blank?
    messages << 'checkin.item_not_found' if !@checkin.item_identifier.blank? and item.blank?
    unless item.blank?
      checkouts = Checkout.where(:item_id => item.id, :checkin_id => nil).order('created_at DESC')
      checked = false
      overdue = false
      checkouts.each do |checkout|
        checked = true if checkout.item.item_identifier == item.item_identifier
        overdue = true if checkout.item.item_identifier == item.item_identifier and checkout.overdue?
      end
      # TODO refactoring
      messages << 'checkin.not_checkin' unless checked
      messages << 'checkin.already_checked_in' if @basket.checkins.collect(&:item).include?(item)
      messages << 'checkin.not_available_for_checkin' if item.available_checkin? == false
    end

    #logger.info flash.inspect
    
    respond_to do |format|
      unless messages.blank?
        #flash[:message], flash[:sound] = error_message_and_sound(message)
        messages.each do |message|
          return_message, return_sound = error_message_and_sound(message)
          flash[:message] << return_message + '<br />'
          flash[:sound] = return_sound if return_sound
        end
        format.html { redirect_to user_basket_checkins_url(@checkin.basket.user, @checkin.basket) }
        format.xml  { render :xml => @checkin.errors.to_xml }
        format.js   { redirect_to user_basket_checkins_url(@checkin.basket.user, @checkin.basket, :mode => 'list', :format => :js) }
      else
        @checkin.item = item
        if @checkin.save(:validate => false)
        # 速度を上げるためvalidationを省略している
          #flash[:message] << t('controller.successfully_created', :model => t('activerecord.models.checkin'))
          #TODO refactoring
          flash[:message] = t('checkin.successfully_checked_in', :model => t('activerecord.models.checkin')) + '<br />'
          item_messages = @checkin.item_checkin(current_user)
          unless item_messages.blank?
            item_messages.each do |message|
              messages << message if message
            end
          end
          messages << 'checkin.overdue_item' if overdue == true
          messages.each do |message|
            return_message, return_sound = error_message_and_sound(message)
            flash[:message] << return_message + '<br />' unless message == 'checkin.other_library_item'
            flash[:message] << t('checkin.other_library', :model => @checkin.item.shelf.library.display_name) + '<br />' if message == 'checkin.other_library_item'
            flash[:sound] = return_sound if return_sound
          end
          format.html { redirect_to user_basket_checkins_url(@checkin.basket.user, @checkin.basket) }
          format.xml  { render :xml => @checkin, :status => :created, :location => user_basket_checkin_url(@checkin.basket.user, @checkin.basket, @checkin) }
          format.js   { redirect_to user_basket_checkins_url(@checkin.basket.user, @checkin.basket, :mode => 'list', :format => :js) }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @checkin.errors.to_xml }
          format.js   { redirect_to user_basket_checkins_url(@basket.user, @basket, :mode => 'list', :format => :js) }
        end
      end
    end
  end

  # PUT /checkins/1
  # PUT /checkins/1.xml
  def update
    #@checkin = Checkin.find(params[:id])
    @checkin.item_identifier = params[:checkin][:item_identifier] rescue nil
    unless @checkin.item_identifier.blank?
      item = Item.where(:item_identifier => @checkin.item_identifier.to_s.strip).first
    end
    @checkin.item = item

    respond_to do |format|
      if @checkin.update_attributes(params[:checkin])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.checkin'))
        format.html { redirect_to checkin_url(@checkin) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @checkin.errors.to_xml }
      end
    end
  end

  # DELETE /checkins/1
  # DELETE /checkins/1.xml
  def destroy
    #@checkin = Checkin.find(params[:id])
    @checkin.destroy

    respond_to do |format|
      format.html { redirect_to checkins_url }
      format.xml  { head :ok }
    end
  end
end
