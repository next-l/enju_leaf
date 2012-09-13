# -*- encoding: utf-8 -*-
class ReservesController < ApplicationController
  include ApplicationHelper
  authorize_resource :only => :index
  before_filter :store_location, :only => [:index, :new]
  load_and_authorize_resource :except => [:index, :show, :edit]
#  load_and_authorize_resource :except => [:index, :show, :edit] :TODO
  before_filter :get_user #, :only => [:show, :edit, :create, :update, :destroy]
  before_filter :store_page, :only => :index
  helper_method :get_manifestation
  helper_method :get_item

  # GET /reserves
  # GET /reserves.json
  def index
    @reserve_user = current_user
    if current_user.has_role?('Librarian')
       @reserve_user = User.find(params[:user_id]) rescue current_user if params[:user_id]
    else
      if @user
        if current_user == @user
          redirect_to user_reserves_path(current_user); return
        else
          access_denied; return
        end
      end
    end

    get_manifestation
    position_update(@manifestation) if @manifestation && params[:mode] == 'position_update'
  
    page = params[:page] || 1
    if params[:mode] == 'hold' and current_user.has_role?('Librarian')
      @reserves = Reserve.hold.order('reserves.created_at DESC').page(page)
    else
      # disp1. user reserves
      if @user
        if current_user.has_role?('Librarian')
          @reserves = @user.reserves.show_reserves.order('reserves.expired_at ASC').page(page)
        else
          @reserves = @user.reserves.user_show_reserves.order('reserves.expired_at ASC').page(page)
        end
      # disp2. manifestation reserves (when position update)
      elsif @manifestation
        @reserves = @manifestation.reserves.can_change_position.order('reserves.position ASC').page(page)
        @in_process_reserves = @manifestation.reserves.in_process
        @completed_reserves = @manifestation.reserves.not_waiting
      # disp3. all reserves
      else
        @states = Reserve.states
        @libraries =  Library.real
        @information_types = Reserve.information_type_ids
        # default selected
        @selected_state = Reserve.show_user_states
        @selected_library = [current_user.library.id]
        @selected_information_type = @information_types
        # push submit?
        if params[:commit]
          @selected_state = params[:state] ? params[:state].inject([]){|states, state| states << state} : []
          @selected_library = params[:library] ? params[:library].inject([]){|ids, id| ids << id.to_i} : []
          @selected_information_type = []
          if params[:information_type]
            @selected_information_type = params[:information_type].map{|i|i.split}
            @selected_information_type = @selected_information_type.inject([]){|types, type|
              type = type.map{|i| i.to_i}
              type = type.join().to_i if type.size == 1
              types << type
            }
          end
        end
        selected_state = @selected_state
        selected_library = @selected_library
        selected_information_type = @selected_information_type.flatten

        flash[:reserve_notice] = "" 
        # check conditions
        error_condition = true if @selected_state.blank? or @selected_library.blank? or @selected_information_type.blank?
        flash[:reserve_notice] << t('item_list.no_list_condition') + '<br />' if error_condition

        # set query
        query = params[:query].to_s.strip
        @query = query.dup
        query = params[:query].gsub("-", "") if params[:query]
        query = "#{query}*" if query.size == 1
        @address = params[:address]
        @date_of_birth = params[:birth_date].to_s.dup
        birth_date = params[:birth_date].to_s.gsub(/\D/, '') if params[:birth_date]
        unless params[:birth_date].blank?
          begin
            date_of_birth = Time.zone.parse(birth_date).beginning_of_day.utc.iso8601
          rescue
            flash[:reserve_notice] << t('user.birth_date_invalid')
          end
        end
        date_of_birth_end = Time.zone.parse(birth_date).end_of_day.utc.iso8601 rescue nil
        query = "#{query} date_of_birth_d:[#{date_of_birth} TO #{date_of_birth_end}]" unless date_of_birth.blank?
        query = "#{query} address_text:#{@address}" unless @address.blank?

        # search
        if (query.blank? and @address.blank? and @date_of_birth.blank?) or error_condition
          @reserves = Reserve.joins(:manifestation).where(:state => selected_state, :receipt_library_id => selected_library, :information_type_id => selected_information_type).order('expired_at ASC').includes(:manifestation).page(page)
        else
          @reserves = Reserve.search do
            fulltext query
            with(:state, selected_state) 
            with(:receipt_library_id, selected_library) 
            with(:information_type_id, selected_information_type)
            order_by(:expired_at, :asc)
            paginate :page => page.to_i, :per_page => Reserve.per_page
          end.results
        end
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @reserves }
      format.rss  { render :layout => false }
      format.atom
      format.csv
      format.pdf  { 
        if @user
          send_data Reserve.get_reserves(@user, current_user).generate, :filename => Setting.reserve_list_user_print.filename
        else
          send_data Reserve.get_reserve_list_all_pdf(query, selected_state, selected_library, selected_information_type).generate,
          :filename => Setting.reserve_list_all_print_pdf.filename, :type => 'application/pdf'
        end
      }
      format.tsv  { 
        if @user
          send_data Reserve.get_reserve_list_user_tsv(@user.id, current_user), :filename => Setting.reserve_list_all_print_tsv.filename
        else
          send_data Reserve.get_reserve_list_all_tsv(query, selected_state, selected_library, selected_information_type),
          :filename => Setting.reserve_list_all_print_tsv.filename 
        end
      }
    end
  end

  # GET /reserves/1
  # GET /reserves/1.json
  def show
    @reserve = Reserve.find(params[:id])
    check_can_access?

    @information_type = Reserve.get_information_type(@reserve)
    @receipt_library = Library.find(@reserve.receipt_library_id)
    @reserved_count = Reserve.waiting.where(:manifestation_id => @reserve.manifestation_id, :checked_out_at => nil).count

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @reserve }
    end
  end

  # GET /reserves/new
  def new
    user = User.where(:user_number => params[:reserve][:user_number]).first if params[:reserve]
    user = @user if @user

    if current_user.blank?
      access_denied; return
    end
    unless current_user.has_role?('Librarian')
      if user.try(:user_number).blank?
        access_denied 
        return
      end
      if user.blank? or user != current_user
        access_denied
        return
      end
    end

    if user
      @reserve = user.reserves.new
    else
      @reserve = Reserve.new
    end
    @libraries = Library.real
    @informations = Reserve.informations(user)
    @reserve.receipt_library_id = user.library_id unless user.blank?

    get_manifestation
    if @manifestation
      unless @manifestation.reservable_with_item?(current_user) 
        access_denied
        return
      end
      @reserve.manifestation = @manifestation
      if user
        @reserve.expired_at = @manifestation.reservation_expired_period(user).days.from_now.end_of_day
        if @manifestation.is_reserved_by(user)
          flash[:notice] = t('reserve.this_manifestation_is_already_reserved')
          redirect_to @manifestation
          return
        end
      end
    end
  end

  # GET /reserves/1/edit
  def edit
    @reserve = Reserve.find(params[:id])
    check_can_access?
    unless @reserve.can_checkout?
      access_denied; return
    end
    if @reserve.retained
      access_denied; return
    end

    user = @user if @user
    @libraries = Library.real
    @informations = Reserve.informations(@reserve.user)
  end

  # POST /reserves
  # POST /reserves.json
  def create
    user = User.where(:user_number => params[:reserve][:user_number]).first if params[:reserve]

    # 図書館員以外は自分の予約しか作成できない
    if current_user.blank?
      access_denied; return
    end
    unless current_user.has_role?('Librarian')
      unless user == current_user
        access_denied; return
      end
    end
    user = @user if @user

    @reserve = Reserve.new(params[:reserve])
    @reserve.user = user
    @reserve.created_by = current_user.id
    @reserve.position = Reserve.waiting.where("manifestation_id = ? AND item_id IS NULL", @reserve.manifestation_id).count + 1

    respond_to do |format|
      if @reserve.save
        # 予約受付のメール送信
        #unless user.email.blank?
        #  ReservationNotifier.deliver_accepted(user, @reserve.manifestation)
        #end
        begin
          @reserve.new_reserve
        rescue Exception => e
          logger.error "Faild to send the reservation message: #{e}"
        end
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.reserve'))
        #format.html { redirect_to reserve_url(@reserve) }
        format.html { redirect_to user_reserve_url(@reserve.user, @reserve) }
        format.json { render :json => @reserve, :status => :created, :location => user_reserve_url(@reserve.user, @reserve) }
      else
        @libraries = Library.real.order('position')
        @informations = Reserve.informations(user)
        format.html { render :action => "new" }
        format.json { render :json => @reserve.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reserves/1
  # PUT /reserves/1.json
  def update
    @reserve = Reserve.find(params[:id])
    unless @reserve.can_checkout? 
      access_denied; return
    end
    if @reserve.retained
      unless params[:mode] == 'cancel'
        access_denied; return
      end
    end

    user = User.where(:user_number => params[:reserve][:user_number]).first if params[:reserve]
    user = @user if @user
    
    get_manifestation
    if @manifestation and params[:position]
      @reserve.insert_at(params[:position].to_i)
      redirect_to manifestation_reserves_url(@manifestation)
      return
    end

    if params[:mode] == 'cancel'
       user = @reserve.user
       @reserve.sm_cancel!
    end

    if user.blank?
      access_denied; return
    end

    if user
      @reserve = user.reserves.find(params[:id])
    end 

    respond_to do |format|
      if @reserve.available_for_update? and @reserve.update_attributes(params[:reserve])
        if @reserve.state == 'canceled'
          flash[:notice] = t('reserve.reservation_was_canceled')
          begin
            @reserve.send_message('canceled')
          rescue Exception => e
            logger.error "Faild to send a notification message (reservation was canceled): #{e}" 
          end
          format.html { redirect_to user_reserves_path(user)}
          format.json { head :no_content }
        else
          flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.reserve'))
          format.html { redirect_to user_reserve_url(@reserve.user, @reserve) }
          format.json { head :no_content }
        end
      else
        @reserve.errors[:base] << t('reserve.expired_at_of_this_user_is_over') unless @reserve.available_for_update?
        @libraries = Library.real.order('position')
        @informations = Reserve.informations(user)
        format.html { render :action => "edit" }
        format.json { render :json => @reserve.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reserves/1
  # DELETE /reserves/1.json
  def destroy
    @reserve = Reserve.find(params[:id])
    if current_user.blank?
      access_denied; return
    end
    unless current_user.has_role?('Librarian')
      if current_user != @reserve.user
        access_denied; return
      end
    end

    reserve = @reserve.dup
    @reserve.destroy
    #flash[:notice] = t('reserve.reservation_was_canceled')

    if reserve.manifestation.is_reserved?
      reserve.position_update(reserve.manifestation)
#      if @reserve.item
#        retain = @reserve.item.retain(User.find('admin')) # TODO: システムからの送信ユーザの設定
#        if retain.nil?
#          flash[:message] = t('reserve.this_item_is_not_reserved')
#        end
#      end
    end

    respond_to do |format|
      format.html { redirect_to reserves_url}
      format.json { head :no_content }
    end
  end

  def output
    @reserve = Reserve.find(params[:reserve_id])
    data = Reserve.get_reserve(@reserve, current_user)
    send_data data.generate, :filename => Setting.reserve_print.filename
  end

  private
  def position_update(manifestation)
    reserves = Reserve.where(:manifestation_id => manifestation).can_change_position.order(:position)
    items = []
    manifestation.items.for_checkout.each do |i|
      items << i if i.available_for_retain?
    end
    reserves.each do |reserve|
      if !items.blank?
        reserve.item = items.shift
        reserve.sm_retain!
      else
        reserve.item = nil
        reserve.sm_request!
        reserve.save
      end
    end
  end

  def check_can_access?
    # logined?
    if current_user.blank?
      access_denied; return
    end
    # has_role? 
    unless current_user.has_role?('Librarian')
      if current_user != @reserve.user
        access_denied; return
      end
      # can show?
      unless @reserve.user_can_show?
        access_denied; return
      end
    end
  end
end
