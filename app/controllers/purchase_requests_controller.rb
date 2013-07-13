class PurchaseRequestsController < ApplicationController
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.purchase_request'))", 'purchase_requests_path', :only => [:index]
  add_breadcrumb "I18n.t('page.showing', :model => I18n.t('activerecord.models.purchase_request'))", 'purchase_request_path(params[:id])', :only => [:show]
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.purchase_request'))", 'new_purchase_request_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.purchase_request'))", 'edit_purchase_request_path(params[:id])', :only => [:edit, :update]
  before_filter :store_location, :only => :index
  load_and_authorize_resource
  before_filter :get_user
  if SystemConfiguration.get("use_order_lists")
    before_filter :get_order_list
  end
  before_filter :store_page, :only => :index
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  after_filter :convert_charset, :only => :index
#  include PageHelper
  include PurchaseRequestsHelper

  # GET /purchase_requests
  # GET /purchase_requests.json
  def index
    unless can_use_purchase_request?
      access_denied; return
    else
      if !user_signed_in?
        if @user
          access_denied; return
        end
      elsif !current_user.has_role?('Librarian')
        if @user
          unless current_user == @user
            access_denied; return
          end
       # else
       #   redirect_to user_purchase_requests_path(current_user); return
        end
      end
    end

    @count = {}
    page = params[:page] || 1
    per_page = params[:format] == 'tsv' ? 65534 : PurchaseRequest.default_per_page
    query = params[:query].to_s.strip
    @query = query.dup
    @state = params[:mode]

    user = @user
    if user_signed_in?
      unless current_user.has_role?('Librarian')
        can_show_all = true unless @user 
      end
    end
    order_list = @order_list
    state = @state
    search = PurchaseRequest.search.build do
      fulltext query if query
      with(:user_id).equal_to 0 unless user_signed_in? #TODO:
      with(:user_id).equal_to user.id if user_signed_in? and user
      with(:user_id, [0, current_user.id]) if can_show_all #TODO:
      with(:order_list_id).equal_to order_list.id if order_list
      with(:state).equal_to state if state
      order_by(:created_at, :desc)
      facet :state
      paginate :page => page.to_i, :per_page => per_page
    end.execute rescue nil
    @state_facet = search.facet(:state).rows
    @purchase_requests = search.results

    @count[:query_result] = @purchase_requests.size
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @purchase_requests }
      format.rss  { render :layout => false }
      format.atom
      format.tsv { send_data PurchaseRequest.get_purchase_requests_tsv(@purchase_requests),
        :filename => Setting.purchase_requests_print_tsv.filename }
    end
  end

  # GET /purchase_requests/1
  # GET /purchase_requests/1.json
  def show
    check_can_access_purchase_request

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @purchase_request }
    end
  end

  # GET /purchase_requests/new
  # GET /purchase_requests/new.json
  def new
    unless can_use_purchase_request?
      access_denied; return
    end

    @purchase_request.user = @user if @user
#    @purchase_request.title = Bookmark.get_title_from_url(@purchase_request.url) unless @purchase_request.title?
    if @purchase_request.manifestation
      @purchase_request.title = @purchase_request.manifestation.original_title
      @purchase_request.isbn = @purchase_request.manifestation.isbn
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @purchase_request }
    end
  end

  # GET /purchase_requests/1/edit
  def edit
    check_can_access_purchase_request

    @purchase_request = PurchaseRequest.find(params[:id])
    if current_user.has_role?('Librarian')
      if @purchase_request.state == "pending" || @purchase_request.state == "rejected"
        @states = [[t('purchase_request.accept'), "accept"], [t('purchase_request.reject'), "reject"]]
      end
    end
  end

  # POST /purchase_requests
  # POST /purchase_requests.json
  def create
    unless can_use_purchase_request?
      access_denied; return
    end

    if @user
      @purchase_request = @user.purchase_requests.new(params[:purchase_request])
    elsif user_signed_in?
      @purchase_request = current_user.purchase_requests.new(params[:purchase_request])
    else
      @purchase_request = PurchaseRequest.new(params[:purchase_request])
      @purchase_request.user_id = 0 #TODO:
    end

    respond_to do |format|
      if @purchase_request.save
        @order_list.purchase_requests << @purchase_request if @order_list
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.purchase_request'))
        if @purchase_request.user
          format.html { redirect_to user_purchase_request_url(@purchase_request.user, @purchase_request) }
        else 
          format.html { redirect_to purchase_request_url(@purchase_request) }
        end
        format.json { render :json => @purchase_request, :status => :created, :location => @purchase_request }
      else
        format.html { render :action => "new" }
        format.json { render :json => @purchase_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /purchase_requests/1
  # PUT /purchase_requests/1.json
  def update
    check_can_access_purchase_request

    if @user
      @purchase_request = @user.purchase_requests.find(params[:id])
    end
    next_state = params[:purchase_request][:next_state]
    respond_to do |format|
       if next_state && @purchase_request.update_attributes_with_state(params[:purchase_request])
#      if next_state && @purchase_request.assign_attributes(params[:purchase_request])
        @purchase_request.send_message(@purchase_request.state, params[:purchase_request][:reason])
        flash[:notice] = t("purchase_request.request_#{@purchase_request.state}")
        if @purchase_request.user
          format.html { redirect_to user_purchase_request_url(@purchase_request.user, @purchase_request) }
        else
          format.html { redirect_to purchase_request_url(@purchase_request) }
        end
        format.json { head :no_content }
      elsif @purchase_request.update_attributes(params[:purchase_request])
        @order_list.purchase_requests << @purchase_request if @order_list
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.purchase_request'))
        if @purchase_request.user
          format.html { redirect_to user_purchase_request_url(@purchase_request.user, @purchase_request) }
        else
          format.html { redirect_to purchase_request_url(@purchase_request) }
        end
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @purchase_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  def accept
    check_can_access_purchase_request

    if @purchase_request.sm_accept
      @purchase_request.send_message(@purchase_request.state)
      flash[:notice] = t('purchase_request.request_accepted')
    else
      flash[:notice] = t('purchase_request.failed_update')
    end

    if @purchase_request.user
      redirect_to user_purchase_request_url(@purchase_request.user, @purchase_request)
    else
      redirect_to purchase_request_url(@purchase_request)
    end
  end
  
  def reject
    check_can_access_purchase_request

    if @purchase_request.sm_reject
      @purchase_request.send_message(@purchase_request.state)
      flash[:notice] = t('purchase_request.request_rejected')
    else
      flash[:notice] = t('purchase_request.failed_update')
    end

    if @purchase_request.user
      redirect_to user_purchase_request_url(@purchase_request.user, @purchase_request)
    else
      redirect_to purchase_request_url(@purchase_request)
    end
  end

  def do_order
    if @purchase_request.sm_order
      flash[:notice] = t('purchase_request.request_ordered')
    else
      flash[:notice] = t('purchase_request.failed_update')
    end

    if @purchase_request.user
      redirect_to user_purchase_request_url(@purchase_request.user, @purchase_request)
    else
      redirect_to purchase_request_url(@purchase_request)
    end
  end

  # DELETE /purchase_requests/1
  # DELETE /purchase_requests/1.json
  def destroy
    unless can_use_purchase_request?
      access_denied; return
    else
      if !user_signed_in?
        access_denied; return
      elsif !current_user.has_role?('Librarian')
        if @user
          unless current_user == @user
            access_denied; return
          end
        else
          redirect_to user_purchase_requests_path(current_user); return
        end
      end
    end

    if @user
      @purchase_request = @user.purchase_requests.find(params[:id])
    end
    @purchase_request.destroy

    respond_to do |format|
      format.html { redirect_to(purchase_requests_url) }
      format.json { head :no_content }
    end
  end

  private
  def check_can_access_purchase_request
    unless can_use_purchase_request?
      access_denied; return
    else
      unless user_signed_in?
        if @purchase_request.user
          access_denied; return
        end
      else
        unless current_user.has_role?('Librarian')
          unless @purchase_request.user_id == 0
            unless @purchase_request.user == current_user
              access_denied; return
            end
          end
        end
      end
    end
  end
end
