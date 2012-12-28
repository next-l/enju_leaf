class BindingItemsController < ApplicationController
  load_and_authorize_resource
  before_filter :get_bookbinding

  # GET /binding_items
  # GET /binding_items.xml
  def index
    if @bookbinding
      @binding_items = @bookbinding.binding_items
      @binding_item = @bookbinding.binding_items.new
    else
      access_denied
      return
    end

    result = render_to_string :partial => 'binding_items/binding_items_list'
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @binding_items }
      format.js  {render :json => {:result => result, :success => 1}}
    end
  end

  # POST /binding_items
  # POST /binding_items.xml
  def create
    if @bookbinding
      @binding_item = BindingItem.new(params[:binding_item])
      @binding_item.bookbinding = @bookbinding
    else
      access_denied
      return
    end

    flash[:message] = []
    item_identifier = @binding_item.item_identifier.to_s.strip
    unless item_identifier.blank?
      item = Item.where(:item_identifier => item_identifier).first
    end
    
    @binding_item.item = item unless item.blank?
    
    respond_to do |format|
      if @binding_item.save
        if @binding_item.item.include_supplements
          flash[:message] << t('item.this_item_include_supplement')
        end
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.binding_item'))

        if params[:mode] == 'list'
          format.html { redirect_to(bookbinding_binding_items_url(@bookbinding, :mode => 'list')) }
          format.xml  { render :xml => @binding_item, :status => :created, :location => @binding_item }
          format.js { redirect_to(bookbinding_binding_items_url(@bookbinding, :format => :js)) }
        else
          flash[:message] << @binding_item.errors[:base]
          format.html { redirect_to(bookbinding_binding_items_url(@bookbinding)) }
          format.xml  { render :xml => @binding_item, :status => :created, :location => @binding_item }
        end
      else
        flash[:message] << @binding_item.errors[:base]
        if params[:mode] == 'list'
          format.html { redirect_to(bookbinding_binding_items_url(@bookbinding, :mode => 'list')) }
          format.xml  { render :xml => @binding_item, :status => :created, :location => @binding_item }
          format.js { redirect_to(bookbinding_binding_items_url(@bookbindinf, :format => :js)) }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @binding_item.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
 
  # DELETE /binding_items/1
  # DELETE /binding_items/1.xml
  def destroy
    if @bookbinding
      @binding_item = @bookbinding.binding_items.find(params[:id])
    else
      access_denied
      return
    end
    @binding_item.destroy

    respond_to do |format|
      format.html { redirect_to(bookbinding_binding_items_url(@bookbinding))}
      format.xml  { head :ok }
    end
  end
end
