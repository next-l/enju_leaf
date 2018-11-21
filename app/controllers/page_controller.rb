class PageController < ApplicationController
  before_action :skip_authorization
  before_action :clear_search_sessions, only: [:index, :advanced_search]
  before_action :authenticate_user!, except: [:index, :advanced_search, :about, :add_on, :msie_accelerator, :opensearch, :statistics, :routing_error]
  before_action :check_librarian, except: [:index, :advanced_search, :about, :add_on, :msie_accelerator, :opensearch, :statistics, :routing_error]
  helper_method :set_libraries

  # トップページを表示します。
  def index
    if user_signed_in?
      session[:user_return_to] = nil
      # unless current_user.agent
      #  redirect_to new_user_agent_url(current_user); return
      # end
      if defined?(EnjuBookmark)
        @tags = current_user.bookmarks.tag_counts.sort{|a, b|
          a.count <=> b.count
        }.reverse
      end
      if current_user.profile
        @manifestation = Manifestation.pickup(
          current_user.profile.keyword_list.to_s.split.sort_by{rand}.first,
          current_user
        )
      else
        @manifestation = nil
      end
    else
      if defined?(EnjuBookmark)
        # TODO: タグ下限の設定
        # @tags = Tag.all(limit: 50, order: 'taggings_count DESC')
        @tags = Bookmark.tag_counts.sort{|a, b|
          a.count <=> b.count
        }.reverse[0..49]
      end
      @manifestation = Manifestation.pickup rescue nil
    end
    set_top_page_content
    @numdocs = Manifestation.search.total

    respond_to do |format|
      format.html
      format.html.phone
    end
  end

  # Internet Explorer用のアクセラレータを表示します。
  def msie_accelerator
    respond_to do |format|
      format.xml { render layout: false }
    end
  end

  # OpenSearch Descriptionファイルを表示します。
  def opensearch
    respond_to do |format|
      format.xml { render layout: false }
    end
  end

  # 詳細検索画面を表示します。
  def advanced_search
    set_libraries
    @title = t('page.advanced_search')
  end

  # 統計画面を表示します。
  def statistics
    @title = t('page.statistics')
  end

  # システム設定画面を表示します。
  def configuration
    @title = t('page.configuration')
  end

  # システム情報画面を表示します。
  def system_information
    @specs = Bundler.load.specs.sort!
  end

  # インポート画面を表示します。
  def import
    @title = t('page.import')
  end

  # エクスポート画面を表示します。
  def export
    @title = t('page.export')
  end

  # 「このシステムについて」を表示します。
  def about
    @title = t('page.about_this_system')
  end

  # 「アドオン」を表示します。
  def add_on
    @title = t('page.add_on')
  end

  # ルーティングエラー画面を表示します。
  def routing_error
    render_404
  end

  private
  def check_librarian
    return true if current_user.has_role?('Librarian')
    access_denied
  end
end
