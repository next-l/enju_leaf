class PurchaseRequestsController < ApplicationController
  before_filter :store_location, :only => :index
  load_and_authorize_resource
  before_filter :get_user_if_nil
  before_filter :get_order_list
  before_filter :store_page, :only => :index
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  after_filter :convert_charset, :only => :index
 
  # GET /purchase_requests
  # GET /purchase_requests.xml
  def index
    if user_signed_in?
      begin
        if !current_user.has_role?('Librarian')
          raise unless current_user == @user
        end
      rescue
        if @user
          unless current_user == @user
            access_denied; return
          end
        else
          redirect_to user_purchase_requests_path(current_user.username)
          return
        end
      end
    end

    @count = {}
    if params[:format] == 'csv'
      per_page = 65534
    else
      per_page = PurchaseRequest.per_page
    end

    query = params[:query].to_s.strip
    @query = query.dup
    mode = params[:mode]

    search = Sunspot.new_search(PurchaseRequest)
    user = @user
    order_list = @order_list
    search.build do
      fulltext query if query.present?
      with(:user_id).equal_to user.id if user
      with(:order_list_id).equal_to order_list.id if order_list
      case mode
      when 'not_ordered'
        with(:ordered).equal_to false
      when 'ordered'
        with(:ordered).equal_to true
      end
      order_by(:created_at, :desc)
    end

    page = params[:page] || 1
    search.query.paginate(page.to_i, per_page)
    begin
      @purchase_requests = search.execute!.results
    rescue RSolr::RequestError
      @purchase_requests = WillPaginate::Collection.create(1,1,0) do end
    end

    @count[:query_result] = @purchase_requests.size

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @purchase_requests }
      format.rss  { render :layout => false }
      format.atom
      format.csv
    end
  rescue RSolr::RequestError
    flash[:notice] = t('page.error_occured')
    redirect_to purchase_requests_url
    return
  end

  # GET /purchase_requests/1
  # GET /purchase_requests/1.xml
  def show
    if @user
      @purchase_request = @user.purchase_requests.find(params[:id])
    else
      @purchase_request = PurchaseRequest.find(params[:id])
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @purchase_request }
    end
  end

  # GET /purchase_requests/new
  # GET /purchase_requests/new.xml
  def new
    begin
      if !current_user.has_role?('Librarian')
        raise unless current_user == @user
      end
    rescue
      access_denied; return
    end

    @purchase_request = PurchaseRequest.new(params[:purchase_request])
    @purchase_request.user = @user if @user
    @purchase_request.title = Bookmark.get_title_from_url(@purchase_request.url) if @purchase_request.title.blank?

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @purchase_request }
    end
  end

  # GET /purchase_requests/1/edit
  def edit
    if @user
      @purchase_request = @user.purchase_requests.find(params[:id])
    else
      @purchase_request = PurchaseRequest.find(params[:id])
    end
  end

  # POST /purchase_requests
  # POST /purchase_requests.xml
  def create
    if @user
      @purchase_request = @user.purchase_requests.new(params[:purchase_request])
    else
      @purchase_request = current_user.purchase_requests.new(params[:purchase_request])
    end

    respond_to do |format|
      if @purchase_request.save
        @order_list.purchase_requests << @purchase_request if @order_list
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.purchase_request'))
        format.html { redirect_to user_purchase_request_url(@purchase_request.user.username, @purchase_request) }
        format.xml  { render :xml => @purchase_request, :status => :created, :location => @purchase_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @purchase_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /purchase_requests/1
  # PUT /purchase_requests/1.xml
  def update
    if @user
      @purchase_request = @user.purchase_requests.find(params[:id])
    else
      @purchase_request = PurchaseRequest.find(params[:id])
    end

    if @purchase_request.url
      unless @purchase_request.url.bookmarkable?
        access_denied; return
      end
    end

    respond_to do |format|
      if @purchase_request.update_attributes(params[:purchase_request])
        @order_list.purchase_requests << @purchase_request if @order_list
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.purchase_request'))
        format.html { redirect_to user_purchase_request_url(@purchase_request.user.username, @purchase_request) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @purchase_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_requests/1
  # DELETE /purchase_requests/1.xml
  def destroy
    if @user
      @purchase_request = @user.purchase_requests.find(params[:id])
    else
      @purchase_request = PurchaseRequest.find(params[:id])
    end
    @purchase_request.destroy

    respond_to do |format|
      if current_user.has_role?('Librarian')
        format.html { redirect_to(purchase_requests_url) }
        format.xml  { head :ok }
      else
        format.html { redirect_to(user_purchase_requests_url(@user.username)) }
        format.xml  { head :ok }
      end
    end
  end

end
