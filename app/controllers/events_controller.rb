# -*- encoding: utf-8 -*-
class EventsController < ApplicationController
  load_and_authorize_resource
  before_filter :get_library, :get_patron
  before_filter :get_libraries, :except => [:index, :destroy]
  #before_filter :get_patron, :only => [:index]
  before_filter :prepare_options
  before_filter :store_page, :only => :index
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  after_filter :convert_charset, :only => :index

  # GET /events
  # GET /events.xml
  def index
    @count = {}
    query = params[:query].to_s.strip
    @query = query.dup
    query = query.gsub('　', ' ')
    tag = params[:tag].to_s if params[:tag].present?
    date = params[:date].to_s if params[:date].present?
    mode = params[:mode]

    search = Sunspot.new_search(Event)
    library = @library
    search.build do
      fulltext query if query.present?
      with(:library_id).equal_to library.id if library
      #with(:tag).equal_to tag
      if date
        with(:start_at).greater_than Time.zone.parse(date).beginning_of_day
        with(:start_at).less_than Time.zone.parse(date).tomorrow.beginning_of_day
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
    search.query.paginate(page.to_i, Event.per_page)
    begin
      @events = search.execute!.results
    rescue RSolr::RequestError
      @events = WillPaginate::Collection.create(1,1,0) do end
    end
    @count[:query_result] = @events.total_entries

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
      format.rss  { render :layout => false }
      format.csv
      format.atom
      format.ics
    end
  rescue RSolr::RequestError
    flash[:notice] = t('page.error_occured')
    redirect_to events_url
    return
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
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
    @event = Event.new(:start_at => date, :end_at => date)
    @event.library = @library

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    prepare_options
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])

    respond_to do |format|
      if @event.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.event'))
        format.html { redirect_to(@event) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])

        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.event'))
        format.html { redirect_to(@event) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end

  private
  def prepare_options
    @event_categories = EventCategory.all
  end

end
