class CheckoutsController < ApplicationController
  before_filter :store_location, :only => :index
  load_and_authorize_resource :except => :output
  before_filter :get_user_if_nil, :only => :index
  before_filter :get_user, :except => :index
  helper_method :get_item
  after_filter :convert_charset, :only => :index

  # GET /checkouts
  # GET /checkouts.xml

  def index
    if params[:icalendar_token].present?
      icalendar_user = User.where(:checkout_icalendar_token => params[:icalendar_token]).first
      if icalendar_user.blank?
        raise ActiveRecord::RecordNotFound
      else
        checkouts = icalendar_user.checkouts.not_returned.order('due_date ASC')
      end
    else
      unless current_user
        access_denied; return
      end
    end

    unless icalendar_user
      if current_user.try(:has_role?, 'Librarian')
        # user checkouts
        if @user
          checkouts = @user.checkouts.not_returned.order('due_date ASC').page(params[:page])
        else
          # all checkouts
          # for select_form
          @libraries = Library.find(:all).collect{|i| [ i.display_name, i.id ] }
          @selected_library = params[:library][:id] unless params[:library].blank?
          library = Library.find(:all).collect{|i| i.id} if params[:library].blank? or params[:library][:id].blank?
          library = params[:library][:id] if params[:library] and !params[:library][:id].blank?

          # over_due
          if params[:view] == 'overdue'
            if params[:days_overdue]
              date = params[:days_overdue].to_i.days.ago.beginning_of_day
            else
              date = 1.days.ago.beginning_of_day
            end
            checkouts = Checkout.overdue(date).joins(:item => [{:shelf => :library}]).where('libraries.id' => library).order('due_date ASC')#.page(params[:page])
          else
          # all
           checkouts = Checkout.not_returned.joins(:item => [{:shelf => :library}]).where('libraries.id' => library).order('due_date ASC')#.page(params[:page])
          end
          #output
          if params[:output]
            output_list(checkouts, params[:view]); return
          end
        end
      else
        # 一般ユーザ
        if current_user == @user
          checkouts = current_user.checkouts.not_returned.order('due_date ASC')
        else
          if @user
            access_denied; return
          else
            redirect_to user_checkouts_url(current_user); return
          end
        end
      end
    end

    @days_overdue = params[:days_overdue] ||= 1
    if params[:format] == 'csv'
      @checkouts = checkouts
    else
      @checkouts = checkouts.page(params[:page])
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @checkouts.to_xml }
      format.rss  { render :layout => false }
      format.ics
      format.csv
      format.atom
    end
  end

  # GET /checkouts/1
  # GET /checkouts/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @checkout.to_xml }
    end
  end

  # GET /checkouts/1;edit
  def edit
    @renew_due_date = @checkout.set_renew_due_date(@user)
  end

  # PUT /checkouts/1
  # PUT /checkouts/1.xml
  def update
    if @checkout.reserved?
      flash[:notice] = t('checkout.this_item_is_reserved')
      redirect_to edit_user_checkout_url(@checkout.user, @checkout)
      return
    end
    if @checkout.over_checkout_renewal_limit?
      flash[:notice] = t('checkout.excessed_renewal_limit')
      unless current_user.has_role?('Librarian')
        redirect_to edit_user_checkout_url(@checkout.user, @checkout)
        return
      end
    end
    if @checkout.overdue?
      flash[:notice] = t('checkout.you_have_overdue_item')
      unless current_user.has_role?('Librarian')
        redirect_to edit_user_checkout_url(@checkout.user, @checkout)
        return
      end
    end
    @checkout.reload
    @checkout.checkout_renewal_count += 1

    respond_to do |format|
      if @checkout.update_attributes(params[:checkout])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.checkout'))
        format.html { redirect_to user_checkout_url(@checkout.user, @checkout) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @checkout.errors.to_xml }
      end
    end
  end

  # DELETE /checkouts/1
  # DELETE /checkouts/1.xml
  def destroy
    @checkout.destroy

    respond_to do |format|
      format.html { redirect_to user_checkouts_url(@checkout.user) }
      format.xml  { head :ok }
    end
  end
  
  def output
    unless @user.blank?
      require 'thinreports'
      report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'checkouts.tlf')

      # checkouts
      checkouts = @user.checkouts.not_returned.order('due_date ASC')

      report.layout.config.list(:list) do
        use_stores :total => 0
        events.on :footer_insert do |e|
          e.section.item(:total).value(checkouts.size)
          e.section.item(:message).value(SystemConfiguration.get("checkouts_print.message"))
        end
      end

      lend_user = User.find(params[:user_id]) rescue nil
      library = Library.find(current_user.library_id) rescue nil

      report.start_new_page do |page|
        page.item(:library).value(LibraryGroup.system_name(@locale))
        page.item(:user).value(@user.user_number)
        page.item(:lend_user).value(lend_user.user_number)
        page.item(:lend_library).value(library.display_name)
        page.item(:lend_library_telephone_number_1).value(library.telephone_number_1)
        page.item(:lend_library_telephone_number_2).value(library.telephone_number_2)
        page.item(:date).value(Time.now.strftime('%Y/%m/%d'))

        checkouts.each do |checkout|
          page.list(:list).add_row do |row|
            row.item(:book).value(checkout.item.manifestation.original_title)
            row.item(:due_date).value(checkout.due_date)
          end
        end
      end
      send_data report.generate, :filename => configatron.checkouts_print.filename, :type => 'application/pdf', :disposition => 'attachment'
    end
  end

  private
  def output_list(checkouts, view)
    require 'thinreports'
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'checkoutlist.tlf')

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
      if view == 'overdue'
        page.item(:page_title).value(t('checkout.listing_overdue_item'))
      else
        page.item(:page_title).value(t('page.listing', :model => t('activerecord.models.checkout')))
      end

      if checkouts.size == 0
        page.list(:list).add_row do |row|
          row.item(:state).value(i18n_state(state))
          row.item(:not_found).show
          row.item(:not_found).value(t('page.no_record_found')) 
        end
      else
        checkouts.each do |checkout| 
          page.list(:list).add_row do |row|
            row.item(:not_found).hide
            user = checkout.user.patron.full_name
            if configatron.checkout_print.old == true and checkout.user.patron.date_of_birth
              age = (Time.now.strftime("%Y%m%d").to_f - checkout.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
              age = age.to_i
              user = user + '(' + age.to_s + t('activerecord.attributes.patron.old')  +')'
            end
            row.item(:user).value(user)
            row.item(:title).value(checkout.item.manifestation.original_title)
            row.item(:item_identifier).value(checkout.item.item_identifier)
            row.item(:library).value(checkout.item.shelf.library.display_name.localize)
            row.item(:shelf).value(checkout.item.shelf.display_name.localize)
            row.item(:due_date).value(checkout.due_date.strftime("%Y/%m/%d"))
            renewal_count = checkout.checkout_renewal_count.to_s + '/' + checkout.item.checkout_status(checkout.user).checkout_renewal_limit.to_s
            row.item(:renewal_count).value(renewal_count)
            due_date_datetype = checkout.due_date.strftime("%Y-%m-%d")
            overdue = Date.today - due_date_datetype.to_date
            overdue = 0 if overdue < 0
            row.item(:overdue).value(overdue)
          end
        end
      end
    end
    send_data report.generate, :filename => configatron.checkoutlist_print.filename, :type => 'application/pdf', :disposition => 'attachment'
  end
end
