class LossItemsController < ApplicationController
  include EnjuLeaf::NotificationSound

  def index
    return access_denied unless (user_signed_in? and current_user.has_role?('Librarian'))
    @loss_items = LossItem.all
  end

  def show
    return access_denied unless (user_signed_in? and current_user.has_role?('Librarian'))
    @loss_item = LossItem.find(params[:id])
  end

  def new
    return access_denied unless (user_signed_in? and current_user.has_role?('Librarian'))
    if params[:item_id] or params[:user_id]
      @loss_item = LossItem.new(:item_id => params[:item_id], :user_id => params[:user_id])
    else
      @loss_item = LossItem.new
    end
  end

  def edit
    return access_denied unless (user_signed_in? and current_user.has_role?('Librarian'))
    @loss_item = LossItem.find(params[:id])
  end

  def create
    return access_denied unless (user_signed_in? and current_user.has_role?('Librarian'))
    LossItem.transaction do 
      flash[:notice] = ""
      @loss_item = LossItem.new(params[:loss_item])
      @loss_item.status = LossItem::UnPaid
      @loss_item.save!
      @item = Item.find(params[:loss_item][:item_id])
      if @item.rent? 
        unless @item.blank?
          get_basket
          unless @basket
            @basket = Basket.new(:user => current_user)
            @basket.save!(:validate => false)
          end
          @checkin = @basket.checkins.new(:item_id => @item.id, :librarian_id => current_user.id)
          @checkin.item = @item
          user_id = @item.checkouts.select {|checkout| checkout.checkin_id.nil?}.first.user_id rescue nil
          if @checkin.save(:validate => false)
            messages = []
            flash[:message] = ''
            flash[:sound] = ''
            flash[:notice] << t('checkin.successfully_checked_in', :model => t('activerecord.models.checkin')) + '<br />'
            item_messages = @checkin.item_checkin(current_user)
            unless item_messages.blank?
              item_messages.each do |message|
                messages << message if message
              end
            end
            messages.each do |message|
              return_message, return_sound = error_message_and_sound(message)
              flash[:message] << return_message + '<br />' if return_message
              flash[:sound] = return_sound if return_sound
            end
          end
        end
      end
      @item.circulation_status = CirculationStatus.where(:name => 'Lost').first
      @item.save!
      flash[:notice] << t('controller.successfully_updated', :model => t('activerecord.models.circulation_status'))
    end
    respond_to do |format|
      format.html { redirect_to loss_item_url(@loss_item) }
      format.xml  { head :ok }
    end
  rescue #Exception => e
    #logger.error "Failed to loss_item: #{e}"
    respond_to do |format|
      flash[:message] = t('activerecord.attributes.item.fail_update_loss_item')
      format.html { render :action => "new" }
      format.xml  { render :xml => @loss_item.errors, :status => :unprocessable_entity }
    end
  end

  def update
    return access_denied unless (user_signed_in? and current_user.has_role?('Librarian'))
    @loss_item = LossItem.find(params[:id])
    LossItem.transaction do 
      @loss_item.status = params[:loss_item][:status]
      @loss_item.note = params[:loss_item][:note]
      @loss_item.save!
      @item = Item.find(@loss_item.item_id)
      @item.circulation_status = CirculationStatus.where(:name => 'Lost').first if @loss_item.status == 0
      @item.circulation_status = CirculationStatus.where(:name => 'Removed').first if @loss_item.status == 1
      @item.save!
      flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.loss_item')) + '<br />'
      flash[:notice] << t('controller.successfully_updated', :model => t('activerecord.models.circulation_status'))
      respond_to do |format|
        format.html { redirect_to(@loss_item) }
      end
    end
  rescue
   flash[:message] = t('activerecord.attributes.loss_item.fail_update')
   respond_to do |format|
     format.html { render :action => "edit" }
     format.xml  { render :xml => @loss_item.errors, :status => :unprocessable_entity }
    end
  end

  def destroy
    return access_denied unless (user_signed_in? and current_user.has_role?('Librarian'))
    @loss_item = LossItem.find(params[:id])
    @loss_item.destroy
    respond_to do |format| 
      format.html { redirect_to(loss_items_url) }
      format.xml  { head :ok }
    end
  end
end
