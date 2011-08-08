class ItemHasUseRestrictionsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_item

  # GET /item_has_use_restrictions
  # GET /item_has_use_restrictions.xml
  def index
    if @item
      @item_has_use_restrictions = @item.item_has_use_restrictions.order('item_has_use_restrictions.id DESC').page(params[:page])
    else
      @item_has_use_restrictions = ItemHasUseRestriction.order('id DESC').page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @item_has_use_restrictions }
    end
  end

  # GET /item_has_use_restrictions/1
  # GET /item_has_use_restrictions/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item_has_use_restriction }
    end
  end

  # GET /item_has_use_restrictions/new
  # GET /item_has_use_restrictions/new.xml
  def new
    @use_restrictions = UseRestriction.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item_has_use_restriction }
    end
  end

  # GET /item_has_use_restrictions/1/edit
  def edit
    @use_restrictions = UseRestriction.all
  end

  # POST /item_has_use_restrictions
  # POST /item_has_use_restrictions.xml
  def create
    @item_has_use_restriction = ItemHasUseRestriction.new(params[:item_has_use_restriction])

    respond_to do |format|
      if @item_has_use_restriction.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.item_has_use_restriction'))
        format.html { redirect_to(@item_has_use_restriction) }
        format.xml  { render :xml => @item_has_use_restriction, :status => :created, :location => @item_has_use_restriction }
      else
        @use_restrictions = UseRestriction.all
        format.html { render :action => "new" }
        format.xml  { render :xml => @item_has_use_restriction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /item_has_use_restrictions/1
  # PUT /item_has_use_restrictions/1.xml
  def update
    respond_to do |format|
      if @item_has_use_restriction.update_attributes(params[:item_has_use_restriction])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.item_has_use_restriction'))
        format.html { redirect_to(@item_has_use_restriction) }
        format.xml  { head :ok }
      else
        @use_restrictions = UseRestriction.all
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item_has_use_restriction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /item_has_use_restrictions/1
  # DELETE /item_has_use_restrictions/1.xml
  def destroy
    @item_has_use_restriction.destroy

    respond_to do |format|
      format.html { redirect_to(item_has_use_restrictions_url) }
      format.xml  { head :ok }
    end
  end
end
