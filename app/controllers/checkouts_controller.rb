class CheckoutsController < ApplicationController
  before_filter :store_location, :only => :index
  before_filter :get_user, :only => :index
  before_filter :get_user_if_nil, :except => :index
  helper_method :get_item
  after_filter :convert_charset, :only => :index

  # GET /checkouts
  # GET /checkouts.json

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
      # logged in as User
      unless current_user.try(:has_role?, 'Librarian')
        if current_user == @user
          # disp1. user checkouts
          checkouts = current_user.checkouts.not_returned.order('due_date ASC')
        else
          if @user
            access_denied
          else
            redirect_to user_checkouts_url(current_user)
          end
          return
        end
      # logged in as Librarian
      else
        if @user
          # disp1. user checkouts
          checkouts = @user.checkouts.not_returned.order('due_date ASC').page(params[:page])
        else
          @libraries = Library.find(:all).collect{|i| [ i.display_name, i.id ] }
          @selected_library = params[:library][:id] unless params[:library].blank?
          library = Library.find(:all).collect{|i| i.id} if params[:library].blank? or params[:library][:id].blank?
          library = params[:library][:id] if params[:library] and !params[:library][:id].blank?
          # disp2. over_due checkouts
          if params[:view] == 'overdue'
            date = 1.days.ago.end_of_day
            date = params[:days_overdue].to_i.days.ago.end_of_day if params[:days_overdue]
            checkouts = Checkout.overdue(date).joins(:item => [{:shelf => :library}]).where('libraries.id' => library).order('due_date ASC')
          else
          # disp3. all checkouts
           checkouts = Checkout.not_returned.joins(:item => [{:shelf => :library}]).where('libraries.id' => library).order('due_date ASC')
          end
        end
      end
    end

    @days_overdue = params[:days_overdue] ||= 1
    @checkouts = checkouts.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @checkouts }
      format.rss  { render :layout => false }
      format.ics
      #format.csv
      format.pdf  { 
        if @user
          send_data Checkout.output_checkouts(checkouts, @user, current_user).generate, :filename => Setting.checkouts_print.filename
        else
          send_data Checkout.output_checkoutlist_pdf(checkouts, params[:view]).generate, :filename => Setting.checkout_list_print_pdf.filename 
        end
      }
      format.tsv  { send_data Checkout.output_checkoutlist_csv(checkouts, params[:view]), :filename => Setting.checkout_list_print_tsv.filename }
      format.atom
    end
  end

  # GET /checkouts/1
  # GET /checkouts/1.json
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
      format.html # show.html.erb
      format.json { render :json => @checkout }
    end
  end

  # GET /checkouts/1/edit
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
  # PUT /checkouts/1.json
  def update
    @checkout = Checkout.find(params[:id])
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
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @checkout.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /checkouts/1
  # DELETE /checkouts/1.json
  def destroy
    @checkout.destroy

    respond_to do |format|
      format.html { redirect_to user_checkouts_url(@checkout.user) }
      format.json { head :no_content }
    end
  end
end
