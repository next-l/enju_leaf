module EnjuLibrary
  module Controller
    extend ActiveSupport::Concern

    included do
      before_action :get_library_group, :set_locale, :set_available_languages, :set_mobile_request
      before_action :store_current_location, unless: :devise_controller?
      rescue_from Pundit::NotAuthorizedError, with: :render_403
      # rescue_from ActiveRecord::RecordNotFound, with: :render_404
      # rescue_from ActionView::MissingTemplate, with: :render_404_invalid_format
    end

    private

    def render_403
      return if performed?

      if user_signed_in?
        respond_to do |format|
          format.html {render template: 'page/403', status: :forbidden}
          # format.html.phone {render template: 'page/403', status: 403}
          format.xml {render template: 'page/403', status: :forbidden}
          format.json { render json: {"error": "forbidden"} }
          format.rss {render template: 'page/403.xml', status: :forbidden}
        end
      else
        respond_to do |format|
          format.html { redirect_to main_app.new_user_session_url }
          # format.html.phone { redirect_to new_user_session_url }
          format.xml { render template: 'page/403', status: :forbidden }
          format.json { render json: {"error": "forbidden"} }
          format.rss { render template: 'page/403.xml', status: :forbidden }
        end
      end
    end

    def render_404
      return if performed?

      respond_to do |format|
        format.html { render template: 'page/404', status: :not_found }
        # format.html.phone { render template: 'page/404', status: 404 }
        format.xml { render template: 'page/404', status: :not_found }
        format.json { render json: {"error": "not_found"} }
        format.rss { render template: 'page/404.xml', status: :not_found }
      end
    end

    def render_404_invalid_format
      return if performed?

      render file: Rails.root.join('public/404.html').to_s, formats: [:html]
    end

    def render_500
      return if performed?

      respond_to do |format|
        format.html {render file: Rails.root.join('public/500.html').to_s, layout: false, status: :internal_server_error}
        # format.html.phone {render file: "#{Rails.root}/public/500", layout: false, status: 500}
        format.xml {render template: 'page/500', status: :internal_server_error}
        format.json { render json: {"error": "server_error"} }
        format.rss {render template: 'page/500.xml', status: :internal_server_error}
      end
    end

    def after_sign_in_path_for(resource)
      session[:locale] = nil
      super
    end

    def set_locale
      if params[:locale]
        unless I18n.available_locales.include?(params[:locale].to_s.intern)
          raise InvalidLocaleError
        end
      end
      if user_signed_in?
        locale = params[:locale] || session[:locale] || current_user.profile.try(:locale).try(:to_sym)
      else
        locale = params[:locale] || session[:locale]
      end
      if locale
        I18n.locale = @locale = session[:locale] = locale.to_sym
      else
        I18n.locale = @locale = session[:locale] = I18n.default_locale
      end
    rescue InvalidLocaleError
      reset_session
      @locale = I18n.default_locale
    end

    def default_url_options(options={})
      {locale: nil}
    end

    def set_available_languages
      if Rails.env.production?
        @available_languages = Rails.cache.fetch('available_languages'){
          Language.where(iso_639_1: I18n.available_locales.map{|l| l.to_s}).select([:id, :iso_639_1, :name, :native_name, :display_name, :position]).all
        }
      else
        @available_languages = Language.where(iso_639_1: I18n.available_locales.map{|l| l.to_s})
      end
    end

    def reset_params_session
      session[:params] = nil
    end

    def not_found
      raise ActiveRecord::RecordNotFound
    end

    def access_denied
      raise Pundit::NotAuthorizedError
    end

    def get_user
      @user = User.find_by(username: params[:user_id]) if params[:user_id]
      # authorize! :show, @user if @user
    end

    def get_user_group
      @user_group = UserGroup.find(params[:user_group_id]) if params[:user_group_id]
    end

    def convert_charset
      case params[:format]
      when 'csv'
        return unless LibraryGroup.site_config.csv_charset_conversion

        # TODO: 他の言語
        if @locale.to_sym == :ja
          headers["Content-Type"] = "text/csv; charset=Shift_JIS"
          response.body = NKF::nkf('-Ws', response.body)
        end
      when 'xml'
        if @locale.to_sym == :ja
          headers["Content-Type"] = "application/xml; charset=Shift_JIS"
          response.body = NKF::nkf('-Ws', response.body)
        end
      end
    end

    def store_page
      if request.get? && request.format.try(:html?) && !request.xhr?
        flash[:page] = params[:page] if params[:page].to_i.positive?
      end
    end

    def set_role_query(user, search)
      role = user.try(:role) || Role.default
      search.build do
        with(:required_role_id).less_than_or_equal_to role.id
      end
    end

    def clear_search_sessions
      session[:query] = nil
      session[:params] = nil
      session[:search_params] = nil
      session[:manifestation_ids] = nil
    end

    def api_request?
      true unless params[:format].nil? || (params[:format] == 'html')
    end

    def get_top_page_content
      if defined?(EnjuNews)
        @news_feeds = Rails.cache.fetch('news_feed_all'){NewsFeed.order(:position)}
        @news_posts = NewsPost.limit(LibraryGroup.site_config.news_post_number_top_page || 10)
      end
      @libraries = Library.real
    end

    def set_mobile_request
      case params[:view]
      when 'phone'
        session[:enju_view] = :phone
      when 'desktop'
        session[:enju_view] = :desktop
      when 'reset'
        session[:enju_view] = nil
      end

      case session[:enju_view].try(:to_sym)
      when :phone
        request.variant = :phone
      when :desktop
        request.variant = nil
      else
        request.variant = :phone if browser.device.mobile?
      end
    end

    def move_position(resource, direction, redirect = true)
      if ['higher', 'lower'].include?(direction)
        resource.send("move_#{direction}")
        if redirect
          redirect_to url_for(controller: resource.class.to_s.pluralize.underscore)
          nil
        end
      end
    end

    def store_current_location
      store_location_for(:user, request.url) if request.format.html?
    end

    def get_library_group
      @library_group = LibraryGroup.site_config
    end

    def get_shelf
      if params[:shelf_id]
        @shelf = Shelf.includes(:library).find(params[:shelf_id])
        authorize @shelf, :show?
      end
    end

    def get_library
      if params[:library_id]
        @library = Library.friendly.find(params[:library_id])
        authorize @library, :show?
      end
    end

    def get_libraries
      @libraries = Library.order(:position)
    end

    def get_bookstore
      if params[:bookstore_id]
        @bookstore = Bookstore.find(params[:bookstore_id])
        authorize @bookstore, :show?
      end
    end

    def get_subscription
      if params[:subscription_id]
        @subscription = Subscription.find(params[:subscription_id])
        authorize @subscription, :show?
      end
    end

    class InvalidLocaleError < StandardError
    end
  end
end
