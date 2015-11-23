require "enju_leaf/engine"
require "enju_leaf/version"
require "enju_leaf/controller"
require "enju_leaf/helper"
require "enju_leaf/localized_name"
require "enju_leaf/url_validator"

require 'csv'
require 'rss'
require 'nkf'
require 'ipaddr'

module EnjuLeaf
  def self.included(base)
    base.extend(ClassMethods)
  end

  module InstanceMethods
    private
    def after_sign_in_path_for(resource)
      session[:locale] = nil
      super
    end

    def render_403
      return if performed?
      if user_signed_in?
        respond_to do |format|
          format.html {render template: 'page/403', status: 403}
          #format.html.phone {render template: 'page/403', status: 403}
          format.xml {render template: 'page/403', status: 403}
          format.json { render text: '{"error": "forbidden"}' }
          format.rss {render template: 'page/403.xml', status: 403}
        end
      else
        respond_to do |format|
          format.html { redirect_to new_user_session_url }
          #format.html.phone { redirect_to new_user_session_url }
          format.xml { render template: 'page/403', status: 403 }
          format.json { render text: '{"error": "forbidden"}' }
          format.rss { render template: 'page/403.xml', status: 403 }
        end
      end
    end

    def render_404
      return if performed?
      respond_to do |format|
        format.html { render template: 'page/404', status: 404 }
        #format.html.phone { render template: 'page/404', status: 404 }
        format.xml { render template: 'page/404', status: 404 }
        format.json { render text: '{"error": "not_found"}' }
        format.rss { render template: 'page/404.xml', status: 404 }
      end
    end

    def render_404_invalid_format
      return if performed?
      render file: "#{Rails.root}/public/404", formats: [:html]
    end

    def render_500
      return if performed?
      respond_to do |format|
        format.html {render file: "#{Rails.root}/public/500", layout: false, status: 500}
        #format.html.phone {render file: "#{Rails.root}/public/500", layout: false, status: 500}
        format.xml {render template: 'page/500', status: 500}
        format.json { render text: '{"error": "server_error"}' }
        format.xml {render template: 'page/500.xml', status: 500}
      end
    end

    def render_500_nosolr
      Rails.logger.fatal("please confirm that the Solr is running.")
      return if performed?
      #flash[:notice] = t('page.connection_failed')
      respond_to do |format|
        format.html {render template: "page/500_nosolr", layout: false, status: 500}
        format.html.phone {render template: "page/500_nosolr", layout: false, status: 500}
        format.xml {render template: 'page/500', status: 500}
        format.json { render text: '{"error": "server_error"}' }
        format.xml {render template: 'page/500.xml', status: 500}
      end
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
      @locale = I18n.default_locale
    end

    def default_url_options(options={})
      {locale: nil}
    end

    def set_available_languages
      if Rails.env == 'production'
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
      @user = User.where(username: params[:user_id]).first if params[:user_id]
      #authorize! :show, @user if @user
    end

    def get_user_group
      @user_group = UserGroup.find(params[:user_group_id]) if params[:user_group_id]
    end

    def convert_charset
      case params[:format]
      when 'csv'
        return unless LibraryGroup.site_config.settings[:csv_charset_conversion]
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
      if request.get? and request.format.try(:html?) and !request.xhr?
        flash[:page] = params[:page] if params[:page].to_i > 0
      end
    end

    def store_location
      if request.get? and request.format.try(:html?) and !request.xhr?
        session[:user_return_to] = request.fullpath
      end
    end

    def set_role_query(user, search)
      role = user.try(:role) || Role.default_role
      search.build do
        with(:required_role_id).less_than_or_equal_to role.id
      end
    end

    def solr_commit
      Sunspot.commit
    end

    def get_version
      @version = params[:version_id].to_i if params[:version_id]
      @version = nil if @version == 0
    end

    def clear_search_sessions
      session[:query] = nil
      session[:params] = nil
      session[:search_params] = nil
      session[:manifestation_ids] = nil
    end

    def api_request?
      true unless params[:format].nil? or params[:format] == 'html'
    end

    def get_top_page_content
      if defined?(EnjuNews)
        @news_feeds = Rails.cache.fetch('news_feed_all'){NewsFeed.order(:position)}
        @news_posts = NewsPost.limit(LibraryGroup.site_config.settings[:news_post_number_top_page] || 10)
      end
      @libraries = Library.real
    end

    def set_mobile_request
      if params[:mobile_view]
        case params[:mobile_view]
        when 'true'
          request.variant = :phone
        when 'false'
          unless params[:format]
            request.variant = nil if request.variant = :phone
          end
        end
      end
    end

    def move_position(resource, direction, redirect = true)
      if ['higher', 'lower'].include?(direction)
        resource.send("move_#{direction}")
        if redirect
          redirect_to url_for(controller: resource.class.to_s.pluralize.underscore)
          return
        end
      end
    end
  end

  class InvalidLocaleError < StandardError
  end
end

ActionController::Base.send(:include, EnjuLeaf)
