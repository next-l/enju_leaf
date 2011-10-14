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
    @manifestations = Manifestation.find(:all, :limit => 10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @manifestations }
    end
  end

  # bestrequest reserve
  def bestrequest
    @title = t('page.best_request')
    @manifestations = Manifestation.find(:all, :limit => 10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @manifestations }
    end
  end

end
