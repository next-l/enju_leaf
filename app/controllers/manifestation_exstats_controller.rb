class ManifestationExstatsController < ApplicationController
  #load_and_authorize_resource
  #after_filter :convert_charset, :only => :show

  def initialize
    @title = ""
    super
  end

  # bestreader checkout
  def bestreader
    @title = t('page.best_reader')
    @start_d = Time.zone.now - 30.days
    @end_d = Time.zone.now
    @limit = 10

    @manifestations_tmp = Manifestation.find(:all, :include => {:items => :checkouts}, :limit => @limit, :conditions => ['checkouts.created_at >= ? AND checkouts.created_at < ?', @start_d, @end_d])

    #@manifestations_tmp.each_with_index do |m, i|
	#logger.info "#{i} #{m.original_title}, #{m.items[0].checkouts.size}"
    #end

    @manifestations = @manifestations_tmp.sort {|a, b|
	b.items[0].checkouts.size <=> a.items[0].checkouts.size
    }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @manifestations }
    end
  end

  # bestrequest reserve
  def bestrequest
    @title = t('page.best_request')
    @start_d = Time.zone.now - 30.days
    @end_d = Time.zone.now
    @limit = 10

    @manifestations_tmp = Manifestation.find(:all, :include => :reserves, :limit => @limit, :conditions => ['reserves.created_at >= ? AND reserves.created_at < ?', @start_d, @end_d])

    @manifestations = @manifestations_tmp.sort {|a, b|
	b.reserves.size <=> a.reserves.size
    }

    #@manifestations.each_with_index do |m, i|
	#logger.info "#{i} #{m.original_title}, #{m.reserves.size}"
    #end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @manifestations }
    end
  end

end
