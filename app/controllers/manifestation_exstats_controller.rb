class ManifestationExstatsController < ApplicationController
  #load_and_authorize_resource
  #after_filter :convert_charset, :only => :show

  def initialize
    @title = ""
    @limit = 20
    @start_d = @end_d = nil
    @select_librarlies = Library.find(:all).collect{|i| [ i.display_name, i.id ] }
    @selected_library = nil
    super
  end

  # bestreader checkout
  def bestreader
    @title = t('page.best_reader')

    # 初期表示
    if !params[:search_date_first] && !params[:search_date_last]
      @start_d = Time.zone.now - 30.days
      @start_date = @start_d.to_s.gsub("-", "")[0..7]
      @end_d = Time.zone.now
      @end_date = @end_d.to_s.gsub("-", "")[0..7]
    # 再検索時
    else
      @start_date = params[:search_date_first]
      @end_date = params[:search_date_last]
      if (@start_date && @end_date) && (@start_date <= @end_date)
        @start_d = datecheck(params[:search_date_first])
        @end_d = datecheck(params[:search_date_last])
        @end_d += 1.days if @end_d
      end
      @selected_library = params[:library][:id]
    end

    if @start_d == nil || @end_d == nil 
      flash[:message] = t('page.exstatistics.invalid_input_date')
      #@manifestations = Manifestation.new
    else
      if @selected_library.nil? || @selected_library.empty?
        @checkouts = Checkout.find_by_sql(["SELECT manifestation_id, COUNT(*) AS cnt FROM checkouts LEFT OUTER JOIN exemplifies on (exemplifies.id = checkouts.item_id) WHERE (checkouts.created_at >= ? and checkouts.created_at < ?) GROUP BY exemplifies.manifestation_id ORDER BY cnt DESC LIMIT ?", @start_d, @end_d, @limit]);
      else
        @checkouts = Checkout.find_by_sql(["SELECT manifestation_id, COUNT(*) AS cnt FROM users, checkouts LEFT OUTER JOIN exemplifies on (exemplifies.id = checkouts.item_id) WHERE checkouts.librarian_id = users.id AND users.library_id = ? AND (checkouts.created_at >= ? and checkouts.created_at < ?) GROUP BY exemplifies.manifestation_id ORDER BY cnt DESC LIMIT ?", @selected_library, @start_d, @end_d, @limit]);
      end

      @manifestations = []
      @checkouts.each do |r|
        @manifestations << Manifestation.find(r.manifestation_id)
      end
    end

    respond_to do |format|
      if @start_d == nil || @end_d == nil
        format.html # { render :action => "new" }
        #format.xml  { render :xml => @manifestations }
      else
        format.html # index.html.erb
        format.xml  { render :xml => @manifestations }
      end
    end
  end

  # bestrequest reserve
  def bestrequest
    @title = t('page.best_request')

    # 初期表示
    if !params[:search_date_first] && !params[:search_date_last]
      @start_d = Time.zone.now - 30.days
      @start_date = @start_d.to_s.gsub("-", "")[0..7]
      @end_d = Time.zone.now
      @end_date = @end_d.to_s.gsub("-", "")[0..7]
    # 再検索時
    else
      @start_date = params[:search_date_first]
      @end_date = params[:search_date_last]
      if (@start_date && @end_date) && (@start_date <= @end_date)
        @start_d = datecheck(params[:search_date_first])
        @end_d = datecheck(params[:search_date_last])
        @end_d += 1.days if @end_d
      end
      @selected_library = params[:library][:id]
    end

    if @start_d == nil || @end_d == nil
      flash[:message] = t('page.exstatistics.invalid_input_date')
      #@manifestations = Manifestation.new
      #@manifestations.errors.add(:message, "Invalid Date")
    else
      if @selected_library.nil? || @selected_library.empty?
        @reserves = Reserve.find(:all, :select=>'manifestation_id, COUNT(*) AS cnt', :limit=>@limit, :conditions => ['reserves.created_at >= ? AND reserves.created_at < ? ',  @start_d, @end_d], :group=>'manifestation_id', :order=>'cnt DESC')
      else
        @reserves = Reserve.find_by_sql(["SELECT reserves.manifestation_id, count(*) as cnt FROM reserves, users WHERE reserves.created_at >= ? AND reserves.created_at < ? AND reserves.user_id = users.id AND users.library_id = ? GROUP BY reserves.manifestation_id ORDER BY cnt DESC LIMIT ?", @start_d, @end_d, @selected_library, @limit])

      end

      @manifestations = []
      @reserves.each do |r|
        @manifestations << Manifestation.find(r.manifestation_id)
      end
    end

    respond_to do |format|
      if @start_d == nil || @end_d == nil
        format.html 
        #format.xml  { render :xml => @manifestations }
      else
        format.html # index.html.erb
        format.xml  { render :xml => @manifestations }
      end
    end
  end

  def datecheck(date_string)
    if date_string == nil || date_string.length != 8 
      return nil
    end

    @year = date_string[0, 4].to_i
    @month = date_string[4, 2].to_i
    @day = date_string[6, 4].to_i
    unless Date.valid_date?(@year, @month, @day)
      return nil
    end

    date = Time.zone.parse(date_string)
  end

end
