class CheckoutsController < ApplicationController
  before_filter :store_location, :only => :index
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

    #output
    if params[:output_checkouts] or params[:output_checkout_list_pdf] or params[:output_checkout_list_tsv]
      if params[:output_checkouts]
        data = Checkout.output_checkouts(checkouts, @user, current_user)
        send_data data.generate, :filename => configatron.checkouts_print.filename
      end
      if params[:output_checkout_list_pdf]
        data = Checkout.output_checkoutlist_pdf(checkouts, params[:view])
        send_data data.generate, :filename => configatron.checkout_list_print_pdf.filename
      end
      if params[:output_checkout_list_tsv]
        data = Checkout.output_checkoutlist_csv(checkouts, params[:view])
        send_data data, :filename => configatron.checkout_list_print_tsv.filename
      end
      return 
    end

    @days_overdue = params[:days_overdue] ||= 1
    @checkouts = checkouts.page(params[:page])
=begin
    if params[:format] == 'csv'
      @checkouts = checkouts
      data = Checkout.output_checkoutlist_csv(checkouts, params[:view])
      send_data data, :filename => configatron.checkoutlist_print_csv.filename
      return
    else
      @checkouts = checkouts.page(params[:page])
    end
=end
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @checkouts.to_xml }
      format.rss  { render :layout => false }
      format.ics
      #format.csv
      format.atom
    end
  end

  # GET /checkouts/1
  # GET /checkouts/1.xml
  def show
    @checkout = Checkout.find(params[:id])
    if current_user.blank?
      access_denied; return
    end
    unless current_user.has_role?('Librarian')  
      unless current_user == @checkout.user
        access_denied; return
      end
    end

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @checkout.to_xml }
    end
  end

  # GET /checkouts/1;edit
  def edit
    @checkout = Checkout.find(params[:id])
    if current_user.blank?
      access_denied; return
    end
    unless current_user.has_role?('Librarian')
      unless current_user == @checkout.user
        access_denied; return
      end
    end

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
end
