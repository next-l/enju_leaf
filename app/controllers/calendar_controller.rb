class CalendarController < ApplicationController
  before_filter :get_library
  
  def index
    params[:month] ||= Time.zone.now.month
    params[:year] ||= Time.zone.now.year
    @month = params[:month].to_i || Time.zone.now.month
    @year = params[:year].to_i || Time.zone.now.year

    #@shown_month = Date.civil(@year, @month)
    @shown_month = Time.zone.local(@year, @month, 1) rescue Time.zone.now

    # TODO: Solrを使って取得
    if @library
      @event_strips = Event.at(@library).event_strips_for_month(@shown_month)
    else
      @event_strips = Event.event_strips_for_month(@shown_month)
    end
  end

  def show
    date = Time.zone.local(params[:year].to_i, params[:month].to_i, params[:day].to_i) rescue Time.zone.now
    date_string = date.strftime('%Y/%m/%d')
    if Event.on(date_string).first
      redirect_to events_path(:date => date_string)
    else
      redirect_to new_event_path(:date => date_string)
    end
  end
  
end
