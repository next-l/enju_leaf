class CheckoutsController < ApplicationController
  before_filter :access_denied, :only => [:new, :create]
  before_filter :store_location, :only => :index
  load_and_authorize_resource
  before_filter :get_user_if_nil, :only => :index
  before_filter :get_user, :except => :index
  before_filter :get_item
  after_filter :convert_charset, :only => :index
  
  # GET /checkouts
  # GET /checkouts.xml

  def index
    @library_group = LibraryGroup.first

    if params[:icalendar_token].present?
      icalendar_user = User.first(:conditions => {:checkout_icalendar_token => params[:icalendar_token]})
      if icalendar_user.blank?
        raise ActiveRecord::RecordNotFound
      else
        @checkouts = icalendar_user.checkouts.not_returned.all(:order => 'created_at DESC')
      end
    elsif user_signed_in?
      if current_user.has_role?('Librarian')
        if @user
          @checkouts = @user.checkouts.not_returned.all(:order => 'created_at DESC')
        else
          if params[:view] == 'overdue'
            if params[:days_overdue]
              date = params[:days_overdue].to_i.days.ago.beginning_of_day
            else
              date = 1.days.ago.beginning_of_day
            end
            @checkouts = Checkout.overdue(date).all(:order => 'created_at DESC')
          else
            @checkouts = Checkout.not_returned.all(:order => 'created_at DESC')
          end
        end
      else
        # 一般ユーザ
        if current_user == @user
          @checkouts = current_user.checkouts.not_returned.all(:order => 'created_at DESC')
        else
          if @user
            access_denied
            return
          else
            redirect_to user_checkouts_path(current_user.username)
            return
          end
        end
      end
    else
      access_denied
      return
    end

     @days_overdue = params[:days_overdue] ||= 1

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @checkouts.to_xml }
      format.rss  { render :layout => false }
      format.ics
      format.csv
      format.atom
      format.pdf {
        prawnto :prawn => {
          :page_layout => :portrait,
          :page_size => "A4"},
        :inline => true
      }
    end

  end

  # GET /checkouts/1
  # GET /checkouts/1.xml
  def show
    @checkout = @user.checkouts.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @checkout.to_xml }
    end
  end

  # GET /checkouts/new
  def new
  #  @checkout = @user.checkouts.new
  end

  # GET /checkouts/1;edit
  def edit
    @checkout = @user.checkouts.find(params[:id])
    @renew_due_date = @checkout.set_renew_due_date(@user)
  end

  # POST /checkouts
  # POST /checkouts.xml
  def create
  #  @checkout = @user.checkouts.new(params[:checkout])
  #
  #  respond_to do |format|
  #    if @checkout.id
  #      flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.checkout'))
  #      format.html { redirect_to user_checkouts_url(@user) }
  #      format.xml  { head :created, :location => checkout_url(@checkout) }
  #    else
  #      #format.html { render :action => "new" }
  #      format.html { redirect_to user_checkouts_url(@user) }
  #      format.xml  { render :xml => @checkout.errors.to_xml }
  #    end
  #  end
  end

  # PUT /checkouts/1
  # PUT /checkouts/1.xml
  def update
    @checkout = @user.checkouts.find(params[:id])
    if @checkout.reserved?
      flash[:notice] = t('checkout.this_item_is_reserved')
      redirect_to edit_user_checkout_url(@checkout.user.username, @checkout)
      return
    end
    if @checkout.over_checkout_renewal_limit?
      flash[:notice] = t('checkout.excessed_renewal_limit')
      redirect_to edit_user_checkout_url(@checkout.user.username, @checkout)
      return
    end
    if @checkout.overdue?
      flash[:notice] = t('checkout.you_have_overdue_item')
      #unless current_user.has_role?('Librarian')
        redirect_to edit_user_checkout_url(@checkout.user.username, @checkout)
        return
      #end
    end
    # もう一度取得しないとvalidationが有効にならない？
    #@checkout = @user.checkouts.find(params[:id])
    @checkout.reload
    @checkout.checkout_renewal_count += 1

    respond_to do |format|
      if @checkout.update_attributes(params[:checkout])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.checkout'))
        format.html { redirect_to user_checkout_url(@checkout.user.username, @checkout) }
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
    @checkout = @user.checkouts.find(params[:id])
    @checkout.destroy

    respond_to do |format|
      format.html { redirect_to user_checkouts_url(@checkout.user.username) }
      format.xml  { head :ok }
    end
  end

end
