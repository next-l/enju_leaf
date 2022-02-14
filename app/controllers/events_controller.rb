class EventsController < ApplicationController
  include EnjuEvent::EnjuLibrariesController
  before_action :store_page, only: :index
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_library, :get_agent
  before_action :get_libraries, except: :destroy
  before_action :prepare_options
  after_action :convert_charset, only: :index

  # GET /events
  # GET /events.json
  def index
    @count = {}
    query = params[:query].to_s.strip
    @query = query.dup
    query = query.gsub('　', ' ')
    tag = params[:tag].to_s if params[:tag].present?
    date = params[:date].to_s if params[:date].present?
    per_page = (params[:format] == "json") ? 500 : Event.default_per_page
    mode = params[:mode]

    search = Sunspot.new_search(Event)
    library = @library
    search.build do
      fulltext query if query.present?
      with(:library_id).equal_to library.id if library
      # with(:tag).equal_to tag
      if date
        with(:start_at).less_than_or_equal_to Time.zone.parse(date)
        with(:end_at).greater_than Time.zone.parse(date)
      end
      if params[:start].present? && params[:end].present?
        with(:start_at).greater_than_or_equal_to Time.zone.parse(params[:start])
        with(:end_at).less_than_or_equal_to Time.zone.parse(params[:end]).end_of_day
      end
      case mode
      when 'upcoming'
        with(:start_at).greater_than Time.zone.now.beginning_of_day
      when 'past'
        with(:start_at).less_than Time.zone.now.beginning_of_day
      end
      order_by(:start_at, :desc)
    end

    page = params[:page] || 1
    search.query.paginate(page.to_i, per_page)
    @events = search.execute!.results
    @count[:query_result] = @events.total_entries

    respond_to do |format|
      format.html # index.html.erb
      format.html.phone
      format.json
      format.rss { render layout: false }
      format.text
      format.atom
      format.ics
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.html.phone
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    prepare_options
    if params[:date]
      begin
        date = Time.zone.parse(params[:date])
      rescue ArgumentError
        date = Time.zone.now.beginning_of_day
        flash[:notice] = t('page.invalid_date')
      end
    else
      date = Time.zone.now.beginning_of_day
    end
    @event = Event.new(start_at: date, end_at: date)
    @event.library = @library

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    prepare_options
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    @event.set_date

    respond_to do |format|
      if @event.save
        flash[:notice] = t('controller.successfully_created', model: t('activerecord.models.event'))
        format.html { redirect_to(@event) }
        format.json { render json: @event, status: :created, location: @event }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])
    @event.set_date

    respond_to do |format|
      if @event.update(event_params)

        flash[:notice] = t('controller.successfully_updated', model: t('activerecord.models.event'))
        format.html { redirect_to(@event) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end

  private
  def set_event
    @event = Event.find(params[:id])
    authorize @event
  end

  def check_policy
    authorize Event
  end

  def event_params
    params.require(:event).permit(
      :library_id, :event_category_id, :name, :note, :start_at,
      :end_at, :all_day, :display_name
    )
  end

  def prepare_options
    @event_categories = EventCategory.all
  end

  def filtered_params
    params.permit([:format, :library_id, :mode, :query, :page, :per_page])
  end

  helper_method :filtered_params
end
