class LossItemsController < ApplicationController
  include NotificationSound
  before_filter :check_librarian
  before_filter :get_user_if_nil
  before_filter :get_patron, :get_manifestation
  helper_method :get_shelf
  helper_method :get_library
  helper_method :get_item

  def index
    @count = {}

    search = Sunspot.new_search(Item)
    set_role_query(current_user, search)
 
    # set query
    query = params[:query].to_s.strip
    @query = query.dup
    query = params[:query].gsub("-", "") if params[:query]
    query = "#{query}*" if query.size == 1
    @date_of_birth = params[:birth_date].to_s.dup
    @address = params[:address]
    birth_date = params[:birth_date].to_s.gsub(/\D/, '') if params[:birth_date]
    unless params[:birth_date].blank?
      begin
        date_of_birth = Time.zone.parse(birth_date).beginning_of_day.utc.iso8601
      rescue
        flash[:message] = t('user.birth_date_invalid')
      end
    end
    date_of_birth_end = Time.zone.parse(birth_date).end_of_day.utc.iso8601 rescue nil

    page = params[:page] || 1
    @status = params[:status]
    if query.blank?
      @loss_items = LossItem.page(page) if @status.blank?
      @loss_items = LossItem.where(:status => @status).page(page) unless @status.blank?
    else
      # search loss_item
      @loss_items = LossItem.search do
        fulltext query
        with(:status).equal_to @status unless @status.blank?
      end.results

      # search item
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

      # search user
      query = "#{query} date_of_birth_d:[#{date_of_birth} TO #{date_of_birth_end}]" unless date_of_birth.blank?
      query = "#{query} address_text:#{@address}" unless @address.blank?
      @users = User.search do
        fulltext query
      end.results
      set_list(@users, @status)

      @loss_items = @loss_items.uniq
      @loss_items = @loss_items.sort{|a, b| b.id <=> a.id}
      @loss_items = @loss_items.paginate({:page => params[:page], :per_page => LossItem.per_page, :total_entries => @loss_items.size})
      #@count[:query_result] = @loss_items.total_entries
    end
  end

  def show
    @loss_item = LossItem.find(params[:id])
  end

  def new
    if params[:item_id] or params[:user_id]
      @inputed = true
      @loss_item = LossItem.new(:item_id => params[:item_id], :user_id => params[:user_id])
    else
      @loss_item = LossItem.new
    end
  end

  def edit
    @inputed = true
    @loss_item = LossItem.find(params[:id])
  end

  def create
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
            item_messages = @checkin.item_checkin(current_user, true)
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
      format.json { head :no_content }
    end
  rescue #Exception => e
    logger.error "Failed to loss_item: #{$!}"
    logger.error "Failed to loss_item: #{$@}"
    respond_to do |format|
      #flash[:message] = t('activerecord.attributes.item.fail_update_loss_item')
      format.html { render :action => "new" }
      format.json { render :json => @loss_item.errors, :status => :unprocessable_entity }
    end
  end

  def update
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
   #flash[:message] = t('activerecord.attributes.loss_item.fail_update')
   respond_to do |format|
     format.html { render :action => "edit" }
     format.json { render :json => @loss_item.errors, :status => :unprocessable_entity }
    end
  end

  def destroy
    @loss_item = LossItem.find(params[:id])
    @loss_item.destroy
    respond_to do |format| 
      format.html { redirect_to(loss_items_url) }
      format.json { head :no_content }
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
