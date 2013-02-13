class BookbindingsController < ApplicationController
#  load_and_authorize_resource
  add_breadcrumb "I18n.t('activerecord.models.bookbinding')", 'bookbindings_path'
  cache_sweeper :item_sweeper, :only => [:create, :update, :destroy]
  cache_sweeper :manifestation_sweeper, :only => [:create, :update, :destroy]
  before_filter :access_denied, :only => :index

  # POST /bookbindings
  # POST /bookbindings.xml
  def create
    @bookbinding = Bookbinding.new

    respond_to do |format|
      if @bookbinding.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.bookbinding'))
        format.html { redirect_to bookbinding_binding_items_url(@bookbinding) }
        format.xml  { render :xml => @bookbinding, :status => :created, :location => @bookbinding }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bookbinding.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bookbindings/1
  # PUT /bookbindings/1.xml
  def update
    @bookbinding = Bookbinding.find(params[:id])
    unless @bookbinding
      redirect_to bookbinding_binding_items_url(@bookbinding)
      return
    end

    respond_to do |format|
      unless (binder = @bookbinding.book_binding).nil?
         if @bookbinding.save
           flash[:notice] = t('bookbinding.bookbinding_completed')
           format.html { redirect_to item_path(binder)}
           format.xml  { head :ok }
         end
      else
        flash[:message] = @bookbinding.errors[:base]
        format.html { redirect_to bookbinding_binding_items_url(@bookbinding)}
        format.xml  { head :ok }
      end
    end
  end

  def index
  end

  def add_binding_item
    item = Item.find(params[:item_id])
    binder_manifestation = Manifestation.find(params[:bookbinder_id])
    bookbinder = binder_manifestation.items.where(:bookbinder => true).first
    respond_to do |format|
      if item.item_bind(bookbinder.id)
        flash[:message] = t('bookbinding.added')
      else
        flash[:message] = "FAILED"
      end
      format.html {redirect_to :controller => 'manifestations', :action => 'index', :bookbinder_id => binder_manifestation.id}
    end    
  end

  def bind_undo
    Item.transaction do
      if params[:manifestation_id]
        binder_manifestation = Manifestation.find(params[:manifestation_id])
        binder_item = binder_manifestation.items.where(:bookbinder => true).first
      elsif params[:item_id]
        binder_item = Item.find(params[:item_id])
        binder_manifestation = binder_item.manifestation
      end
      items = Item.find(:all, :conditions => ["bookbinder_id=? AND bookbinder IS FALSE", binder_item.id])
      items.each do |item|
        item.bookbinder_id = nil
        item.circulation_status_id = 5 # In Process
        item.save!
      end
      binder_item.destroy
      binder_manifestation.destroy if binder_manifestation.items.blank?
      flash[:message] = t('bookbinding.unbinded')
    end  
    # TODO when cannot unbind
    respond_to do |format|
      format.html { redirect_to manifestations_path }
      format.xml  { head :ok }
    end
  end
end
