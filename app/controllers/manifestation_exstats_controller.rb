class ManifestationExstatsController < ApplicationController

  def initialize
    @limit = 20
    @offset = 0
    @start_d = (Time.zone.now - 30.days).to_s[0..9]
    @end_d = Time.zone.now.to_s[0..9]
    @select_librarlies = Library.find(:all).collect{|i| [ i.display_name, i.id ] }
    @rank = 1
    @ranks = []
    @Rank = Struct.new(:rank, :manifestation)
#    @selected_library = nil
    super
  end

  def bestreader
    if params[:search_date_first] || params[:search_date_last]
      @start_d = params[:search_date_first]
      @end_d = params[:search_date_last]
      @selected_library = params[:library][:id]
    end
    flash[:message] = date_check(@start_d, @end_d)
    return unless flash[:message].blank?
  
    i = 0
    @checkouts = []
    while @rank <= @limit
      if @selected_library.nil? || @selected_library.empty?
        @checkout_parts = Checkout.find_by_sql(["SELECT manifestation_id, 
          COUNT(*) AS cnt FROM checkouts LEFT OUTER 
          JOIN exemplifies on (exemplifies.id = checkouts.item_id) 
          WHERE (checkouts.created_at >= ? and checkouts.created_at < ?) 
          GROUP BY exemplifies.manifestation_id 
          ORDER BY cnt DESC LIMIT ? OFFSET ?", @start_d, @end_d.to_time + 1.days, @limit, @offset]);
      else
        @checkout_parts = Checkout.find_by_sql(["SELECT manifestation_id, 
          COUNT(*) AS cnt FROM users, checkouts LEFT OUTER 
          JOIN exemplifies on (exemplifies.id = checkouts.item_id) 
          WHERE checkouts.user_id = users.id AND users.library_id = ? AND (checkouts.created_at >= ? and checkouts.created_at < ?) 
          GROUP BY exemplifies.manifestation_id 
          ORDER BY cnt DESC LIMIT ? OFFSET ?", @selected_library, @start_d, @end_d.to_time + 1.days, @limit, @offset]);
      end
      break if @checkout_parts.length == 0

      @checkout_parts.each do |c|
        @checkouts << c
      end

      while i < @checkouts.length
        @rank = i + 1 unless @checkouts[i].cnt == @checkouts[i-1].cnt
        @manifestation = Manifestation.find(@checkouts[i].manifestation_id)
        @ranks << @Rank.new(@rank, @manifestation) if @rank <= @limit
        i += 1
      end
      @offset += @limit
    end
  end

  def bestrequest
    if params[:search_date_first] && params[:search_date_last]
      @start_d = params[:search_date_first]
      @end_d = params[:search_date_last]
      @selected_library = params[:library][:id]
    end
    flash[:message] = date_check(@start_d, @end_d)
    return unless flash[:message].blank?

    i = 0
    @reserves = []
    while @rank <= @limit
      if @selected_library.nil? || @selected_library.empty?
        @reserve_parts = Reserve.find(:all, :select=>'manifestation_id, COUNT(*) AS cnt', :limit=>@limit, :offset =>@offset,
          :conditions => ['reserves.created_at >= ? AND reserves.created_at < ? ',  @start_d, @end_d.to_time + 1.days], 
          :group=>'manifestation_id', :order=>'cnt DESC')
      else
        @reserve_parts = Reserve.find_by_sql(["SELECT reserves.manifestation_id, count(*) as cnt FROM reserves, users 
          WHERE reserves.created_at >= ? AND reserves.created_at < ? AND reserves.user_id = users.id AND users.library_id = ? 
          GROUP BY reserves.manifestation_id ORDER BY cnt DESC LIMIT ? OFFSET ?", @start_d, @end_d.to_time + 1.days, @selected_library, @limit, @offset])
      end
      break if @reserve_parts.length == 0

      @reserve_parts.each do |r|
        @reserves << r
      end

      while i < @reserves.length
        @rank = i + 1 unless @reserves[i].cnt == @reserves[i-1].cnt
        @manifestation = Manifestation.find(@reserves[i].manifestation_id)
        @ranks << @Rank.new(@rank, @manifestation) if @rank <= @limit
        i += 1
      end
      @offset += @limit
    end
  end

  private
  def date_check(start_d, end_d)
    if start_d.blank? || end_d.blank?
      return t('page.exstatistics.nil_date')
    elsif !start_d =~ /^[+-]?\d+$/ || !end_d =~ /^[+-]?\d+$/
      return t('page.exstatistics.invalid_input_date')
    elsif date_format_check(start_d) == nil
      return t('page.exstatistics.invalid_input_date')
    elsif date_format_check(end_d) == nil
      return t('page.exstatistics.invalid_input_date')
    elsif end_d < start_d
      return t('page.exstatistics.over_end_date')
    end
    nil
  end

  def date_format_check(date_string)
    date_string = date_string.to_s.gsub(/\D/, '')
    return nil if date_string == nil || date_string.length != 8 

    @year = date_string[0, 4].to_i
    @month = date_string[4, 2].to_i
    @day = date_string[6, 4].to_i
    return nil unless Date.valid_date?(@year, @month, @day)

    date = Time.zone.parse(date_string)
  end
end
