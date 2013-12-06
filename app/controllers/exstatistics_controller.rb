class ExstatisticsController < ApplicationController

  def initialize
    @title = ""
    super
  end

  def index
    @numdocs = Manifestation.search.total
    # TODO: タグ下限の設定
    #@tags = Tag.all(:limit => 50, :order => 'taggings_count DESC')
    @tags = Bookmark.tag_counts.sort{|a,b| a.count <=> b.count}.reverse[0..49]
    @manifestation = Manifestation.pickup rescue nil

    @title = t('page.statistics')
  end

  def manifestations
    action_mode = params[:mode].to_s
    case action_mode 
    when 'bestreader'
      @title = t('page.best_reader')
      @manifestations = Manifestation.find(:all, :limit => 10)
    when 'bestrequest'
      @title = t('page.best_request')
      @manifestations = Manifestation.find(:all, :limit => 10)
    end
  end

  def routing_error
    render_404
  end

  private
end
