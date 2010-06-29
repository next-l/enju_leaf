class MessagesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_user_if_nil, :only => :index
  after_filter :solr_commit, :only => [:create, :update, :destroy, :destroy_selected]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /messages
  # GET /messages.xml
  def index
    unless @user
      redirect_to user_messages_url(current_user.username)
      return
    end
    query = params[:query].to_s.strip
    search = Sunspot.new_search(Message)
    user = current_user
    case params[:mode]
    when 'read'
      is_read = true
    when 'unread'
      is_read = false
    else
      is_read = nil
    end
    search.build do
      fulltext query
      order_by :created_at, :desc
      with(:receiver_id).equal_to user.id
      facet(:is_read)
    end
    @message_facet = search.execute!.facet('is_read').rows
    search.build do
      with(:is_read).equal_to is_read unless is_read.nil?
    end
    page = params[:page] || 1
    search.query.paginate(page.to_i, Message.per_page)
    @messages = search.execute!.results
    current_user.received_messages.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @messages }
      format.rss
      format.atom
    end
  end

  # GET /messages/1
  # GET /messages/1.xml
  def show
    @message = current_user.received_messages.find(params[:id])
    @message.sm_read!

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @message }
    end
  end

  # GET /messages/new
  def new
    parent = get_parent(params[:parent_id])
    @message = current_user.sent_messages.new
    if params[:recipient] && current_user.has_role?('Librarian')
      @message.recipient = params[:recipient]
    else
      @message.recipient = parent.sender.username if parent
    end
  end

  # GET /messages/1;edit
  def edit
    @message = current_user.received_messages.find(params[:id])
    @message.sm_read!
  end

  # POST /messages
  # POST /messages.xml
  def create
    @message = current_user.sent_messages.new(params[:message])
    get_parent(@message.parent_id)
    @message.receiver = User.find(@message.recipient) rescue nil

    respond_to do |format|
      if @message.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.message'))
        format.html { redirect_to user_messages_url(current_user.username) }
        format.xml  { render :xml => @message, :status => :created, :location => @message }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.xml
  def update
    @message = current_user.received_messages.find(params[:id])
    
    if @message.update_attributes(params[:message])
      flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.message'))
      format.html { redirect_to message_url(@message) }
      format.xml  { head :ok }
    else
      format.html { render :action => "edit" }
      format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.xml
  def destroy
    @message = current_user.received_messages.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to user_messages_url(current_user) }
      format.xml  { head :ok }
    end
  end

  def destroy_selected
    if current_user
      unless current_user.has_role?('Librarian')
        access_denied
      end
    else
      redirect_to new_user_session_url
      return
    end
    respond_to do |format|
      if params[:delete].present?
        messages = params[:delete].map{|m| Message.find_by_id(m)}
      end
      if messages.present?
        messages.each do |message|
          message.destroy
        end
        flash[:notice] = t('message.messages_were_deleted')
        format.html { redirect_to user_messages_url(current_user) }
      else
        flash[:notice] = t('message.select_messages')
        format.html { redirect_to user_messages_url(current_user) }
      end
    end
  end

  private
  def get_parent(id)
    parent = Message.first(:conditions => {:id => id})
    unless current_user.has_role?('Librarian')
      unless parent.try(:receiver) == current_user
        access_denied; return
      end
    else
      parent
    end
  end
end
