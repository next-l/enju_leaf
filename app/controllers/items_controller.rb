class ItemsController < ApplicationController
  include EnjuInventory::Controller
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_agent, :get_manifestation, :get_shelf, except: [:create, :update, :destroy]
  before_action :get_inventory_file
  before_action :get_library, :get_item, except: [:create, :update, :destroy]
  before_action :prepare_options, only: [:new, :edit]
  before_action :get_version, only: [:show]
  after_action :convert_charset, only: :index

  # GET /items
  # GET /items.json
  def index
    query = params[:query].to_s.strip
    per_page = Item.default_per_page
    @count = {}
    if user_signed_in?
      if current_user.has_role?('Librarian')
        if request.format.text?
          per_page = 65534
        elsif params[:mode] == 'barcode'
          per_page = 40
        end
      end
    end

    if defined?(InventoryFile)
      if @inventory_file
        if user_signed_in?
          if current_user.has_role?('Librarian')
            case params[:inventory]
            when 'not_in_catalog'
              mode = 'not_in_catalog'
            else
              mode = 'not_on_shelf'
            end
            order = 'items.id'
            @items = Item.inventory_items(@inventory_file, mode).order(order).page(params[:page]).per(per_page)
          else
            access_denied
            return
          end
        else
          redirect_to new_user_session_url
          return
        end
      end
    end

    unless @inventory_file
      search = Sunspot.new_search(Item)
      selected_attributes = [
        :id, :item_identifier, :call_number, :manifestation_id, :acquired_at,
        :binding_item_identifier, :binding_call_number, :binded_at,
        :include_supplements, :url, :note,
        :circulation_status_id, :shelf_id,
        :created_at, :updated_at
      ]
      selected_attributes += [
        :memo, :required_role_id, :budget_type_id, :bookstore_id, :price
      ] if current_user.try(:has_role?, 'Librarian')
      search.data_accessor_for(Item).select = selected_attributes
      set_role_query(current_user, search)

      @query = query.dup
      if query.present?
        search.build do
          fulltext query
        end
      end

      agent = @agent
      manifestation = @manifestation
      shelf = @shelf
      unless params[:mode] == 'add'
        search.build do
          with(:agent_ids).equal_to agent.id if agent
          with(:manifestation_id).equal_to manifestation.id if manifestation
          with(:shelf_id).equal_to shelf.id if shelf
          with(:circulation_status).equal_to params[:circulation_status] if params[:circulation_status].present?
          facet :circulation_status if defined?(EnjuCirculation)
        end
      end

      search.build do
        order_by(:created_at, :desc)
      end

      role = current_user.try(:role) || Role.default
      search.build do
        with(:required_role_id).less_than_or_equal_to role.id
      end

      if params[:acquired_from].present?
        begin
          acquired_from = Time.zone.parse(params[:acquired_from]).beginning_of_day
          @acquired_from = acquired_from.strftime('%Y-%m-%d')
        rescue ArgumentError
        rescue NoMethodError
        end
      end
      if params[:acquired_until].present?
        begin
          acquired_until = @acquired_until = Time.zone.parse(params[:acquired_until]).end_of_day
          @acquired_until = acquired_until.strftime('%Y-%m-%d')
        rescue ArgumentError
        rescue NoMethodError
        end
      end
      search.build do
        with(:acquired_at).greater_than_or_equal_to acquired_from.beginning_of_day if acquired_from
        with(:acquired_at).less_than acquired_until.tomorrow.beginning_of_day if acquired_until
      end

      page = params[:page] || 1
      search.query.paginate(page.to_i, per_page)
      result = search.execute
      @circulation_status_facet = result.facet(:circulation_status).rows if defined?(EnjuCirculation)
      @items = result.results
      @count[:total] = @items.total_entries
    end

    if defined?(EnjuBarcode)
      if params[:mode] == 'barcode'
        render action: 'barcode', layout: false
        return
      end
    end

    flash[:page_info] = { page: page, query: query }

    respond_to do |format|
      format.html # index.html.erb
      format.json
      format.text
      format.atom
    end
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @manifestation = @item.manifestation unless @manifestation

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end

  # GET /items/new
  def new
    if Shelf.real.blank?
      flash[:notice] = t('item.create_shelf_first')
      redirect_to libraries_url
      return
    end
    unless @manifestation
      flash[:notice] = t('item.specify_manifestation')
      redirect_to manifestations_url
      return
    end
    if @manifestation.series_master?
      flash[:notice] = t('item.specify_manifestation')
      redirect_to manifestations_url(parent_id: @manifestation.id)
      return
    end
    @item = Item.new
    @item.shelf = @library.shelves.first
    @item.manifestation = @manifestation
    if defined?(EnjuCirculation)
      @circulation_statuses = CirculationStatus.where(
        name: [
          'In Process',
          'Available For Pickup',
          'Available On Shelf',
          'Claimed Returned Or Never Borrowed',
          'Not Available']
      ).order(:position)
      @item.circulation_status = CirculationStatus.find_by(name: 'In Process')
      @item.checkout_type = @manifestation.carrier_type.checkout_types.first
      @item.item_has_use_restriction = ItemHasUseRestriction.new
      @item.item_has_use_restriction.use_restriction = UseRestriction.find_by(name: 'Not For Loan')
    end
  end

  # GET /items/1/edit
  def edit
    @item.library_id = @item.shelf.library_id
    @manifestation = @item.manifestation
    if defined?(EnjuCirculation)
      unless @item.use_restriction
        @item.build_item_has_use_restriction
        @item.item_has_use_restriction.use_restriction = UseRestriction.find_by(name: 'Not For Loan')
      end
    end
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)
    manifestation = Manifestation.find(@item.manifestation_id)

    respond_to do |format|
      if @item.save
        @item.manifestation = manifestation
        Item.transaction do
          if defined?(EnjuCirculation)
            if @item.reserved?
              flash[:message] = t('item.this_item_is_reserved')
              @item.retain(current_user)
            end
          end
        end
        format.html { redirect_to(@item, notice: t('controller.successfully_created', model: t('activerecord.models.item'))) }
        format.json { render json: @item, status: :created, location: @item }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: t('controller.successfully_updated', model: t('activerecord.models.item')) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    manifestation = @item.manifestation
    @item.destroy

    respond_to do |format|
      flash[:notice] = t('controller.successfully_deleted', model: t('activerecord.models.item'))
      if @item.manifestation
        format.html { redirect_to items_url(manifestation_id: manifestation.id) }
        format.json { head :no_content }
      else
        format.html { redirect_to items_url }
        format.json { head :no_content }
      end
    end
  end

  private
  def set_item
    @item = Item.find(params[:id])
    authorize @item
  end

  def check_policy
    authorize Item
  end

  def item_params
    params.require(:item).permit(
      :call_number, :item_identifier, :circulation_status_id,
      :checkout_type_id, :shelf_id, :include_supplements, :note, :url, :price,
      :acquired_at, :bookstore_id, :missing_since, :budget_type_id,
      :lock_version, :manifestation_id, :library_id, :required_role_id,
      :binding_item_identifier, :binding_call_number, :binded_at,
      :use_restriction_id, :memo,
      {item_has_use_restriction_attributes: :use_restriction_id}, # EnjuCirculation
      {item_custom_values_attributes: [
        :id, :item_custom_property_id, :item_id, :value,:_destroy
      ]}
    )
  end

  def prepare_options
    @libraries = Library.order(:position)
    if @item
      @library = @item.shelf.library
    else
      @library = Library.real.includes(:shelves).order(:position).first
    end
    @shelves = @library.try(:shelves)
    @bookstores = Bookstore.order(:position)
    @budget_types = BudgetType.order(:position)
    @roles = Role.all
    if defined?(EnjuCirculation)
      @circulation_statuses = CirculationStatus.order(:position)
      @use_restrictions = UseRestriction.available
      if @manifestation
        @checkout_types = CheckoutType.available_for_carrier_type(@manifestation.carrier_type)
      else
        @checkout_types = CheckoutType.order(:position)
      end
    end
  end
end
