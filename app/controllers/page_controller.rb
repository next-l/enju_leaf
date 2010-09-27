class PageController < ApplicationController
  before_filter :redirect_user, :only => :index
  before_filter :clear_search_sessions, :only => [:index, :advanced_search]
  before_filter :store_location, :only => [:advanced_search, :about, :add_on, :msie_acceralator, :statistics]
  before_filter :authenticate_user!, :except => [:index, :advanced_search, :about, :add_on, :msie_acceralator, :opensearch, :statistics]
  before_filter :get_libraries, :only => [:advanced_search]
  before_filter :check_librarian, :except => [:index, :advanced_search, :about, :add_on, :msie_acceralator, :opensearch]

  def index
    @numdocs = Manifestation.search.total
    # TODO: タグ下限の設定
    #@tags = Tag.all(:limit => 50, :order => 'taggings_count DESC')
    @tags = Bookmark.tag_counts.sort{|a,b| a.count <=> b.count}.reverse[0..49]
    @manifestation = Manifestation.pickup rescue nil
  end

  def msie_acceralator
    render :layout => false
  end

  def opensearch
    render :layout => false
  end

  def advanced_search
    @title = t('page.advanced_search')
  end

  def statistics
    @title = t('page.statistics')
  end
  
  def configuration
    @title = t('page.configuration')
  end

  def import
    @title = t('page.import')
  end
  
  def export
    @title = t('page.export')
  end
  
  def about
    @title = t('page.about_this_system')
  end

  def add_on
    @title = t('page.add_on')
  end

  def under_construction
    @title = t('page.under_construction')
  end

  private
  def check_librarian
    unless current_user.has_role?('Librarian')
      access_denied
    end
  end
 
  def redirect_user
    if user_signed_in?
      redirect_to user_url(current_user.username)
      return
    end
  end
end
