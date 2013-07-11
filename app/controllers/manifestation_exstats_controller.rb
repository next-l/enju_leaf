class ManifestationExstatsController < ApplicationController
  add_breadcrumb "I18n.t('page.best_reader')", 'manifestation_exstats_bestreader_path', :only => [:bestreaser]
  add_breadcrumb "I18n.t('page.best_request')", 'manifestation_exstats_bestrequest_path', :only => [:bestrequest]

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
    if params[:opac] and params[:search_date_first].blank? and params[:search_date_last].blank?
      @start_d = (Date.today - 2.weeks).to_s
      @end_d = Date.today.to_s
    end
    if params[:search_date_first] || params[:search_date_last]
      @start_d = params[:search_date_first]
      @end_d = params[:search_date_last]
      @selected_library = params[:library][:id] if params[:library]
    end
    flash[:message] = ApplicationController.helpers.term_check(@start_d, @end_d)
    unless flash[:message].blank?
      render :template => 'opac/manifestation_exstats/bestreader', :layout => 'opac' if params[:opac]
      return
    end

 
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
        @manifestation = Manifestation.where(:id => @checkouts[i].manifestation_id).first
        @ranks << @Rank.new(@rank, @manifestation) if @rank <= @limit
        i += 1
      end
      @offset += @limit
    end
    render :template => 'opac/manifestation_exstats/bestreader', :layout => 'opac' if params[:opac]
  end

  def bestrequest
    logger.info "bestrequest start"
    if params[:opac] and params[:search_date_first].blank? and params[:search_date_last].blank?
      @start_d = (Date.today - 2.weeks).to_s
      @end_d = Date.today.to_s
    end
      
    if params[:search_date_first] && params[:search_date_last]
      @start_d = params[:search_date_first]
      @end_d = params[:search_date_last]
      @selected_library = params[:library][:id] if params[:library]
    end
    flash[:message] = ApplicationController.helpers.term_check(@start_d, @end_d)
    unless flash[:message].blank?
      render :template => 'opac/manifestation_exstats/bestrequest', :layout => 'opac' if params[:opac]
      return
    end

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

    render :template => 'opac/manifestation_exstats/bestrequest', :layout => 'opac' if params[:opac]
  end
end
