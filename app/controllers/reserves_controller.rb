# -*- encoding: utf-8 -*-
class ReservesController < ApplicationController
  include ReservesHelper
  include ApplicationHelper
  before_filter :store_location, :only => [:index, :new]
  load_and_authorize_resource :except => [:index, :output_user]
  authorize_resource :only => :index
  before_filter :get_user_if_nil
  #, :only => [:show, :edit, :create, :update, :destroy]
  helper_method :get_manifestation
  helper_method :get_item
  before_filter :store_page, :only => :index

  # GET /reserves
  # GET /reserves.xml
  def index
    if current_user.try(:has_role?, 'Librarian') && params[:user_id]
      @reserve_user = User.find(params[:user_id]) rescue current_user
    else
      @reserve_user = current_user
    end

    @reserve_user_id = params[:user_id] if params[:user_id]
    unless current_user.has_role?('Librarian')
      if @user
        unless current_user == @user
          access_denied; return
        end
      else
        redirect_to user_reserves_path(current_user); return
      end
    end

    get_manifestation
    position_update(@manifestation) if @manifestation && params[:mode] == 'position_update'
  
    if params[:mode] == 'hold' and current_user.has_role?('Librarian')
      @reserves = Reserve.hold.order('reserves.created_at DESC').page(params[:page])
    else
      if @user
        # 一般ユーザ
        if current_user.has_role?('Librarian')
          @reserves = @user.reserves.show_reserves.order('reserves.expired_at ASC').page(params[:page])
        else
          @reserves = @user.reserves.user_show_reserves.order('reserves.expired_at ASC').page(params[:page])
        end
        # 管理者
      elsif @manifestation
        @reserves = @manifestation.reserves.not_retained.order('reserves.position ASC').page(params[:page])
        @completed_reserves = @manifestation.reserves.not_waiting.page(params[:page])
      else
        # all reserves
        page = params[:page] || 1
        @states = Reserve.states
        @libraries =  Library.all
        @selected_library = []
        @libraries.each do |library|
          @selected_library << library.id
        end
        @information_types = @selected_method =  Reserve.information_types
        # first move
        if params[:do_search].blank?
          @selected_state = @states.reject{|x| x == 'completed' || x == 'expired' || x == 'canceled'}
          @reserves = Reserve.show_reserves.where(:state => @selected_state).order('expired_at ASC').includes(:manifestation).page(page)
          return
        end

        flash[:reserve_notice] = "" 

        # check list_conditions
        params[:state] ? @selected_state = params[:state].clone : @selected_state = []
        params[:library] ? @selected_library = params[:library].clone : @selected_library = []
        params[:method] ? @selected_method = params[:method].clone : @selected_method = []
        params[:method].concat(['3', '4', '5', '6', '7']) if !params[:method].blank? and params[:method].include?('2')
        if params[:state].blank? || params[:library].blank? || params[:method].blank? 
          flash[:reserve_notice] << t('item_list.no_list_condition') + '<br />'
        end
        states = nil

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

        if query.blank? and @address.blank? and @date_of_birth.blank?
          @reserves = Reserve.where(:state => params[:state], :receipt_library_id => params[:library], :information_type_id => params[:method]).order('expired_at ASC').includes(:manifestation).page(page)
        else 
          query = "#{query} date_of_birth_d: [#{date_of_birth} TO #{date_of_birth_end}]" unless date_of_birth.blank?
          query = "#{query} address_text: #{@address}" unless @address.blank?
          @reserves = Reserve.search do
            fulltext query
            with(:state, params[:state])
            with(:receipt_library_id, params[:library])
            with(:information_type_id, params[:method])
            order_by(:expired_at, :asc)
            paginate :page => page.to_i, :per_page => Reserve.per_page
          end.results
        end

        # output
        if params[:state].present? and params[:library].present? and params[:method].present?
          if params[:output_pdf]
            output_list_with_search_pdf(query, params[:state], params[:library], params[:method])
          elsif params[:output_csv]
            output_list_with_search_csv(query, params[:state], params[:library], params[:method])
          end
        end 
     end
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @reserves.to_xml }
      format.rss  { render :layout => false }
      format.atom
      format.csv
      return
    end
  end

  # GET /reserves/1
  # GET /reserves/1.xml
  def show
    @information_method = Reserve.get_information_method(@reserve)
    @receipt_library = Library.find(@reserve.receipt_library_id)
    @reserved_count = Reserve.waiting.where(:manifestation_id => @reserve.manifestation_id, :checked_out_at => nil).count
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @reserve.to_xml }
    end
  end

  # GET /reserves/new
  def new
    user = User.where(:user_number => params[:reserve][:user_number]).first if params[:reserve]
    user = @user if @user

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
    @libraries = Library.all
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

  # GET /reserves/1;edit
  def edit
    unless @reserve.can_checkout?
      access_denied; return
    end
    user = @user if @user
    @libraries = Library.all
    @informations = Reserve.informations(user)
  end

  # POST /reserves
  # POST /reserves.xml
  def create
    user = User.where(:user_number => params[:reserve][:user_number]).first if params[:reserve]

    # 図書館員以外は自分の予約しか作成できない
    unless current_user.has_role?('Librarian')
      unless user == current_user
        access_denied
        return
      end
    end
    user = @user if @user
 
    @reserve = Reserve.new(params[:reserve])
    @reserve.user = user
    @reserve.created_by = current_user.id

    respond_to do |format|
      if @reserve.save
        # 予約受付のメール送信
        #unless user.email.blank?
        #  ReservationNotifier.deliver_accepted(user, @reserve.manifestation)
        #end
        begin
          @reserve.new_reserve
          @reserve.send_message('accepted')
        rescue Exception => e
          logger.error "Faild to send the reservation message: #{e}"
        end
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.reserve'))
        #format.html { redirect_to reserve_url(@reserve) }
        format.html { redirect_to user_reserve_url(@reserve.user, @reserve) }
        format.xml  { render :xml => @reserve, :status => :created, :location => user_reserve_url(@reserve.user, @reserve) }
      else
        @libraries = Library.order('position')
        @informations = Reserve.informations(user)
        format.html { render :action => "new" }
        format.xml  { render :xml => @reserve.errors.to_xml }
      end
    end
  end

  # PUT /reserves/1
  # PUT /reserves/1.xml
  def update
    unless @reserve.can_checkout?
      access_denied
      return
    end

    if params[:reserve]
      user = User.where(:user_number => params[:reserve][:user_number]).first
    end
    user = @user if @user
    
    get_manifestation
    if @manifestation and params[:position]
      @reserve.insert_at(params[:position])
      redirect_to manifestation_reserves_url(@manifestation)
      return
    end

    if params[:mode] == 'cancel'
       user = @reserve.user
       @reserve.sm_cancel!
    end

    if user.blank?
      access_denied
      return
    end

    if user
      @reserve = user.reserves.find(params[:id])
    end

    respond_to do |format|
      if @reserve.update_attributes(params[:reserve])
        if @reserve.state == 'canceled'
          flash[:notice] = t('reserve.reservation_was_canceled')
          begin
            @reserve.send_message('canceled')
          rescue Exception => e
            logger.error "Faild to send a notification message (reservation was canceled): #{e}" 
          end
          format.html { redirect_to user_reserves_path(user)}
          format.xml  { head :ok }
        else
          flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.reserve'))
          format.html { redirect_to user_reserve_url(@reserve.user, @reserve) }
          format.xml  { head :ok }
        end
      else
        @libraries = Library.order('position')
        @informations = Reserve.informations(user)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reserve.errors.to_xml }
      end
    end
  end

  # DELETE /reserves/1
  # DELETE /reserves/1.xml
  def destroy
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
      format.xml  { head :ok }
    end
  end

  def output
    @reserve_library = Library.find(current_user.library_id)
    @receipt_library = Library.find(@reserve.receipt_library_id)

    require 'thinreports'
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'reserve.tlf') 
    report.start_new_page do |page|
      # library info
      user = @reserve.user.user_number
      if SystemConfiguration.get("reserve_print.old") == true and  @reserve.user.patron.date_of_birth
        age = (Time.now.strftime("%Y%m%d").to_f - @reserve.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
        age = age.to_i
        user = user + '(' + age.to_s + t('activerecord.attributes.patron.old')  +')'
      end
      page.item(:library).value(LibraryGroup.system_name(@locale))
      page.item(:date).value(Time.now)
      page.item(:created_at).value(@reserve.created_at.strftime("%Y/%m/%d"))
      page.item(:expired_at).value(@reserve.expired_at.strftime("%Y/%m/%d"))
      page.item(:user).value(user)
      page.item(:receipt_library).value(@receipt_library.display_name)
      page.item(:receipt_library_telephone_number_1).value(@receipt_library.telephone_number_1)
      page.item(:receipt_library_telephone_number_2).value(@receipt_library.telephone_number_2)
      page.item(:information_method).value(i18n_information_type(@reserve.information_type_id))
      page.item(:user_information).value(Reserve.get_information_method(@reserve))
      # book info
      page.item(:title).value(@reserve.manifestation.original_title)
      page.item(:creater).value(patrons_list(@reserve.manifestation.creators.readable_by(current_user), {:itemprop => 'author', :nolink => true}))
      page.item(:publisher).value(patrons_list(@reserve.manifestation.publishers.readable_by(current_user), {:itemprop => 'publisher', :nolink => true}))
      page.item(:price).value(@reserve.manifestation.price)
      page.item(:page).value(@reserve.manifestation.number_of_pages.to_s + 'p') if @reserve.manifestation.number_of_pages 
      page.item(:size).value(@reserve.manifestation.height.to_s + 'cm') if @reserve.manifestation.height
      page.item(:isbn).value(@reserve.manifestation.isbn)
    end    
    send_data report.generate, :filename => configatron.reserve_print.filename, :type => 'application/pdf', :disposition => 'attachment'
  end

  def output_user
    @user = User.find(params[:user_id])
    if current_user.has_role?('Librarian')    
      reserves = Reserve.show_reserves.where(:user_id => @user.id).order('expired_at Desc')
    else
      reserves = Reserve.user_show_reserves.where(:user_id => @user.id).order('expired_at Desc')
    end 
    #reserves = Reserve.where(:user_id => @user.id).order('expired_at Desc')
    require 'thinreports'
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'reservelist_user.tlf') 
    report.layout.config.list(:list) do
      events.on :footer_insert do |e|
        e.section.item(:total).value(reserves.length)
        e.section.item(:date).value(Time.now)
      end
    end
    report.start_new_page do |page|
      page.item(:library).value(LibraryGroup.system_name(@locale))
      user = @user.patron.full_name
      if SystemConfiguration.get("reserve_print.old") == true and @user.patron.date_of_birth
        age = (Time.now.strftime("%Y%m%d").to_f - @user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
        age = age.to_i
        user = user + '(' + age.to_s + t('activerecord.attributes.patron.old')  +')'
      end
      page.item(:user).value(user)
      @user_library = Library.find(@user.library_id)
      page.item(:user_library).value(@user_library.display_name)
      page.item(:user_library_telephone_number_1).value(@user_library.telephone_number_1)
      page.item(:user_library_telephone_number_2).value(@user_library.telephone_number_2)
      page.item(:user_telephone_number_1_1).value(@user.patron.telephone_number_1)
      page.item(:user_telephone_number_1_2).value(@user.patron.extelephone_number_1)
      page.item(:user_telephone_number_1_3).value(@user.patron.fax_number_1)
      page.item(:user_telephone_number_2_1).value(@user.patron.telephone_number_2)
      page.item(:user_telephone_number_2_2).value(@user.patron.extelephone_number_2)
      page.item(:user_telephone_number_2_3).value(@user.patron.fax_number_2)
      page.item(:user_email).value(@user.email)

      reserves.each do |reserve|
        page.list(:list).add_row do |row|
          row.item(:title).value(reserve.manifestation.original_title)
          row.item(:state).value(i18n_state(reserve.state))
          row.item(:receipt_library).value(Library.find(reserve.receipt_library_id).display_name)
          row.item(:information_method).value(i18n_information_type(reserve.information_type_id))
          row.item(:expired_at).value(reserve.expired_at.strftime("%Y/%m/%d"))
        end
      end
    end    
    send_data report.generate, :filename => configatron.reservelist_user_print.filename, :type => 'application/pdf', :disposition => 'attachment'
  end

  private
  def output_list_with_search_pdf(query, states, library, method)
    require 'thinreports'
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'reservelist.tlf')

    # set page_num
    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end

    report.start_new_page do |page|
      page.item(:date).value(Time.now)

      before_state = nil
      states.each do |state|
        reserves = []
        if query.blank?
          reserves = Reserve.where(:state => state, :receipt_library_id => library, :information_type_id => method).order('expired_at ASC').includes(:manifestation)
        else
          reserves = Reserve.search do
            fulltext query
            with(:state).equal_to(state)
            with(:receipt_library_id, library) unless library.blank?
            with(:information_type_id, method) unless method.blank?
            order_by(:expired_at, :asc)
          end.results
        end

        before_receipt_library = nil
        unless reserves.blank?
          reserves.each do |r|
            page.list(:list).add_row do |row|
             row.item(:not_found).hide
             if before_state == state
               row.item(:state_line).hide
               row.item(:state).hide
             end
             if before_receipt_library == r.receipt_library_id and before_state == state
               row.item(:receipt_library_line).hide
               row.item(:receipt_library).hide
             end
               row.item(:state).value(i18n_state(state))
               row.item(:receipt_library).value(Library.find(r.receipt_library_id).display_name)
               row.item(:title).value(r.manifestation.original_title)
               row.item(:expired_at).value(r.expired_at.strftime("%Y/%m/%d"))
               user = r.user.patron.full_name
               if SystemConfiguration.get("reserve_print.old") == true and  r.user.patron.date_of_birth
                 age = (Time.now.strftime("%Y%m%d").to_f - r.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
                 age = age.to_i
                 user = user + '(' + age.to_s + t('activerecord.attributes.patron.old')  +')'
               end
               row.item(:user).value(user)
               information_method = i18n_information_type(r.information_type_id)
               information_method += ': ' + Reserve.get_information_method(r) if r.information_type_id != 0 and !Reserve.get_information_method(r).nil?
               row.item(:information_method).value(information_method)
            end
            before_receipt_library = r.receipt_library_id
            before_state = state
          end
        else
          page.list(:list).add_row do |row|
            row.item(:state).value(i18n_state(state))
            row.item(:not_found).show
            row.item(:not_found).value(t('page.no_record_found'))
            row.item(:line2).hide
            row.item(:line3).hide
            row.item(:line4).hide
            row.item(:line5).hide
          end
        end
      end
      send_data report.generate, :filename => configatron.reservelist_all_print_pdf.filename, :type => 'application/pdf', :disposition => 'attachment'
    end
  end
 
  def output_list_with_search_csv(query, states, library, method)
    out_dir = "#{RAILS_ROOT}/private/system/reserves/"
    csv_file = out_dir + configatron.reservelist_all_print_csv.filename 
    logger.info "output reservelist csv: #{csv_file}"

    # create output path
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)

    columns = [
      [:state,'activerecord.attributes.reserve.state'],
      [:receipt_library, 'activerecord.attributes.reserve.receipt_library'],
      [:title, 'activerecord.attributes.manifestation.original_title'],
      [:expired_at,'activerecord.attributes.reserve.expired_at2'],
      [:user, 'activerecord.attributes.reserve.user'],
      [:information_method, 'activerecord.attributes.reserve.information_method'],
    ]

    File.open(csv_file, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # title column
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      output.print row.join(",")+"\n"

      states.each do |state|
  #     reserves = []
        # get reserves
        if query.blank?
          reserves = Reserve.where(:state => state, :receipt_library_id => library, :information_type_id => method).order('expired_at ASC').includes(:manifestation)
        else
          reserves = Reserve.search do
            fulltext query
            with(:state).equal_to(state)
            with(:receipt_library_id, library) unless library.blank?
            with(:information_type_id, method) unless method.blank?
            order_by(:expired_at, :asc)
          end.results
        end
        
        # set
        reserves.each do |reserve|
          row = []
          columns.each do |column|
            case column[0]
            when :title
              row << i18n_state(state)
            when :receipt_library
              row << Library.find(reserve.receipt_library_id).display_name
            when :title
              row << reserve.manifestation.original_title
            when :expired_at
              row << reserve.expired_at.strftime("%Y/%m/%d")
            when :user
              user = reserve.user.patron.full_name
              if SystemConfiguration.get("reserve_print.old") == true and  reserve.user.patron.date_of_birth
                age = (Time.now.strftime("%Y%m%d").to_f - reserve.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
                age = age.to_i
                user = user + '(' + age.to_s + t('activerecord.attributes.patron.old')  +')'
              end
              row << user
            when :information_method
              information_method = i18n_information_type(reserve.information_type_id)
              information_method += ': ' + Reserve.get_information_method(reserve) if reserve.information_type_id != 0 and !Reserve.get_information_method(reserve).nil?
              row << information_method
            end # end of case column[0]
          end #end of columns.each
          output.print '"'+row.join('","')+"\"\n"
        end # end of items.each
      end
    end
    send_file csv_file
  end

  def position_update(manifestation)
    reserves = Reserve.where(:manifestation_id => manifestation).not_retained.order(:position)
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
end
