class ManifestationExstatsController < ApplicationController
  #load_and_authorize_resource
  #after_filter :convert_charset, :only => :show

  def initialize
    @title = ""
    @limit = 10
    @start_d = @end_d = nil
    super
  end

  # bestreader checkout
  def bestreader
    @title = t('page.best_reader')

    # 初期表示
    if !params[:number_of_pages_at_least] && !params[:number_of_pages_at_most]
      @start_d = Time.zone.now - 30.days
      @end_d = Time.zone.now
    # 再検索時
    elsif params[:number_of_pages_at_least] && params[:number_of_pages_at_most]
      if params[:number_of_pages_at_least] <= params[:number_of_pages_at_most]
        @start_d = datecheck(params[:number_of_pages_at_least])
        @end_d = datecheck(params[:number_of_pages_at_most])
        @end_d += 1.days if @end_d 
        #logger.info  "start_d = #{@start_d} end_d = #{@end_d}"
      end
    end

    if @start_d == nil || @end_d == nil 
      flash[:message] = t('page.exstatistics.invalid_input_date')
      #@manifestations = Manifestation.new
    else
      #@checkouts = Checkout.find(:all, :select=>'item_id, COUNT(*) AS cnt', :limit=>@limit, :conditions => ['checkouts.created_at >= ? AND checkouts.created_at < ? ',  @start_d, @end_d], :group=>'item_id', :order=>'cnt DESC')
      @checkouts = Checkout.find_by_sql(["SELECT  item_id, COUNT(*) AS cnt FROM checkouts WHERE (checkouts.created_at>= ? AND checkouts.created_at < ?) GROUP BY item_id ORDER BY cnt DESC LIMIT ?", @start_d, @end_d, @limit])

      @manifestations = []
      @checkouts.each do |r|
        @manifestations << Manifestation.find(:first, :include => :items, :conditions => ['items.id = ?', r.item_id])
      end
    end

    respond_to do |format|
      if @start_d == nil || @end_d == nil
        format.html { render :action => "new" }
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
    if !params[:number_of_pages_at_least] && !params[:number_of_pages_at_most]
      @start_d = Time.zone.now - 30.days
      @end_d = Time.zone.now
    # 再検索時
    elsif params[:number_of_pages_at_least] && params[:number_of_pages_at_most]
      if params[:number_of_pages_at_least] <= params[:number_of_pages_at_most]
        @start_d = datecheck(params[:number_of_pages_at_least])
        @end_d = datecheck(params[:number_of_pages_at_most])
        @end_d += 1.days if @end_d
        #logger.info  "start_d = #{@start_d} end_d = #{@end_d}"
      end
    end

    if @start_d == nil || @end_d == nil
      flash[:message] = t('page.exstatistics.invalid_input_date')
      #@manifestations = Manifestation.new
      #@manifestations.errors.add(:message, "Invalid Date")
    else
      @reserves = Reserve.find(:all, :select=>'manifestation_id, COUNT(*) AS cnt', :limit=>@limit, :conditions => ['reserves.created_at >= ? AND reserves.created_at < ? ',  @start_d, @end_d], :group=>'manifestation_id', :order=>'cnt DESC')

      @manifestations = []
      @reserves.each do |r|
        @manifestations << Manifestation.find(r.manifestation_id)
      end
    end

    respond_to do |format|
      if @start_d == nil || @end_d == nil
        format.html { render :action => "new" }
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
