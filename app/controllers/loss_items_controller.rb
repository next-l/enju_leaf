class LossItemsController < ApplicationController
  include EnjuLeaf::NotificationSound
  before_filter :get_user_if_nil
  before_filter :get_patron, :get_manifestation
  helper_method :get_shelf
  helper_method :get_library
  helper_method :get_item

  def index
    return access_denied unless (user_signed_in? and current_user.has_role?('Librarian'))

    query = params[:query].to_s.strip
    @query = query.dup
    @count = {}

    search = Sunspot.new_search(Item)
    set_role_query(current_user, search)

    query = params[:query].gsub("-", "") if params[:query]
    query = "#{query}*" if query.size == 1

    # page = params[:page] || 1
    @status = params[:status]
    if query.blank?
      #@loss_items = LossItem.page(page) if @status.blank?
      #@loss_items = LossItem.where(:status => @status).page(page) unless @status.blank?
      @loss_items = LossItem.all if @status.blank?
      @loss_items = LossItem.where(:status => @status) unless @status.blank?
    else
      # search loss_item
      @loss_items = LossItem.search do
        fulltext query
        with(:status).equal_to @status unless @status.blank?
      end.results
    end

    # search item
    unless query.blank?
      patron = @patron
      manifestation = @manifestation
      shelf = get_shelf
      @items = Item.search do
        with(:patron_ids).equal_to patron.id if patron
        with(:manifestation_id).equal_to manifestation.id if manifestation
        with(:shelf_id).equal_to shelf.id if shelf
        fulltext query
      end.results
      set_list(@items, @status)
    end

    # search user
    @date_of_birth = params[:birth_date].to_s.dup
    birth_date = params[:birth_date].to_s.gsub(/\D/, '') if params[:birth_date]
    unless params[:birth_date].blank?
      begin
        date_of_birth = Time.zone.parse(birth_date).beginning_of_day.utc.iso8601
      rescue
        flash[:message] = t('user.birth_date_invalid')
      end
    end
    date_of_birth_end = Time.zone.parse(birth_date).end_of_day.utc.iso8601 rescue nil
    address = params[:address]
    @address = address
    query = "#{query} date_of_birth_d: [#{date_of_birth} TO #{date_of_birth_end}]" unless date_of_birth.blank?
    query = "#{query} address_text: #{address}" unless address.blank?
    unless query.blank?
      @users = User.search do
        fulltext query
      end.results
      set_list(@users, @status)
    end

    @loss_items = @loss_items.uniq
    @loss_items = @loss_items.sort{|a, b| b.id <=> a.id}
    #@count[:query_result] = @loss_items.total_entries
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
              flash[:message] << return_message + '<br />' unless message == 'checkin.other_library_item'
              flash[:message] << t('checkin.other_library', :model => @checkin.item.shelf.library.display_name) + '<br />' if message == 'checkin.other_library_item'
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

  private
  def set_list(obj, status)
    unless obj.blank?
      obj.each do |i|
        @same_items =  LossItem.where(:item_id => i.id) if obj == @items and status.blank?
        @same_items =  LossItem.where(:item_id => i.id, :status => status) if obj == @items and !status.blank?
        @same_items =  LossItem.where(:user_id => i.id) if obj == @users and status.blank?
        @same_items =  LossItem.where(:user_id => i.id, :status => status) if obj == @users and !status.blank?
        if @same_items.length > 0 
          @same_items.each do |s|
            @loss_items << s
          end
        end
      end
    end 
  end
end
