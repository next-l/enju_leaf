class AcceptsController < InheritedResources::Base
  load_and_authorize_resource :except => :index
  authorize_resource :only => :index
  respond_to :html, :json
  before_filter :get_basket, :only => [:index, :create]

  # GET /accepts
  # GET /accepts.json
  def index
    # かごがない場合、自動的に作成する
    unless @basket
      @basket = Basket.create!(:user => current_user)
      redirect_to basket_accepts_url(@basket)
      return
    end
    @accepts = @basket.accepts.order('accepts.created_at DESC').all

    @accept = @basket.accepts.new

    respond_to do |format|
      format.html # index.rhtml
      format.json { render :json => @accepts }
      format.js
    end
  end

  # POST /accepts
  # POST /accepts.json
  def create
    unless @basket
      @basket = Basket.new(:user => current_user)
      @basket.save(:validate => false)
    end
    @accept = @basket.accepts.new(params[:accept])
    @accept.librarian = current_user

    flash[:message] = ''
    if @accept.item_identifier.blank?
      flash[:message] << t('accept.enter_item_identifier') if @accept.item_identifier.blank?
    else
      item = Item.where(:item_identifier => @accept.item_identifier.to_s.strip).first
    end

    unless item
      flash[:message] << t('accept.item_not_found')
    else
      if @basket.accepts.collect(&:item).include?(item)
        flash[:message] << t('accept.already_accepted')
      end
    end

    respond_to do |format|
      unless item
        format.html { redirect_to basket_accepts_url(@accept.basket) }
        format.json { render :json => @accept.errors, :status => :unprocessable_entity }
        format.js {
          redirect_to basket_accepts_url(@accept.basket, :mode => 'list', :format => :js)
        }
      else
        @accept.item = item
        if @accept.save
          flash[:message] << t('accept.successfully_accepted', :model => t('activerecord.models.accept'))
          format.html { redirect_to basket_accepts_url(@accept.basket) }
          format.json { render :json => @accept, :status => :created, :location => @accept }
          format.js {
            redirect_to basket_accepts_url(@accept.basket, :mode => 'list', :format => :js)
          }
        else
          format.html { render :action => "new" }
          format.json { render :json => @accept.errors, :status => :unprocessable_entity }
          format.js {
            redirect_to basket_accepts_url(@basket, :mode => 'list', :format => :js)
          }
        end
      end
    end
  end
end
