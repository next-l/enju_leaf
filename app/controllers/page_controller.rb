class PageController < ApplicationController
  before_filter :clear_search_sessions, only: [:index, :advanced_search]
  before_filter :store_location, only: [:advanced_search, :about, :add_on, :msie_acceralator, :statistics]
  before_filter :authenticate_user!, except: [:index, :advanced_search, :about, :add_on, :msie_acceralator, :opensearch, :statistics, :routing_error]
  before_filter :check_librarian, except: [:index, :advanced_search, :about, :add_on, :msie_acceralator, :opensearch, :statistics, :routing_error]
  helper_method :get_libraries

  def index
    if user_signed_in?
      session[:user_return_to] = nil
      #unless current_user.agent
      #  redirect_to new_user_agent_url(current_user); return
      #end
      if defined?(EnjuBookmark)
        @tags = current_user.bookmarks.tag_counts.sort{|a,b| a.count <=> b.count}.reverse
      end
      @manifestation = Manifestation.pickup(current_user.keyword_list.to_s.split.sort_by{rand}.first, current_user) rescue nil
    else
      if defined?(EnjuBookmark)
        # TODO: タグ下限の設定
        #@tags = Tag.all(:limit => 50, :order => 'taggings_count DESC')
        @tags = Bookmark.tag_counts.sort{|a,b| a.count <=> b.count}.reverse[0..49]
      end
      @manifestation = Manifestation.pickup rescue nil
    end
    get_top_page_content
    @numdocs = Manifestation.search('*').results.total

    respond_to do |format|
      format.html
      format.html.phone
    end
  end

  def msie_acceralator
    respond_to do |format|
      format.xml { render layout: false }
    end
  end

  def opensearch
    respond_to do |format|
      format.xml { render layout: false }
    end
  end

  def advanced_search
    get_libraries
    @title = t('page.advanced_search')
  end

  def statistics
    @title = t('page.statistics')
  end

  def configuration
    @title = t('page.configuration')
  end

  def system_information
    @specs = Bundler.load.specs.sort
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

  def routing_error
    render_404
  end

  private
  def check_librarian
    unless current_user.has_role?('Librarian')
      access_denied
    end
  end
end
