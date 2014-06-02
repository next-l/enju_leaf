require "enju_leaf/engine"
require "enju_leaf/version"
require "enju_leaf/controller"
require "enju_leaf/user"
require "enju_leaf/helper"

require 'csv'
#require 'mathn'
require 'rss'
require 'nkf'
require 'ipaddr'
require 'plugins'

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
      respond_to do |format|
        format.html {
          if user_signed_in?
            render :template => 'page/403', :status => 403
          else
            redirect_to new_user_session_url
          end
        }
        #format.mobile {render :template => 'page/403', :status => 403}
        format.xml {render :template => 'page/403', :status => 403}
        format.json { render :text => '{"error": "forbidden"}' }
        format.rss {render :template => 'page/403', :status => 403, :formats => 'xml'}
        format.csv {render :template => 'page/403', :status => 403, :formats => 'html'}
      end
    end

    def render_404
      return if performed?
      respond_to do |format|
        format.html {render :template => 'page/404', :status => 404}
        #format.mobile {render :template => 'page/404', :status => 404}
        format.xml {render :template => 'page/404', :status => 404}
        format.json { render :text => '{"error": "not_found"}' }
        format.rss {render :template => 'page/404', :status => 404, :formats => 'xml'}
        format.csv {render :template => 'page/403', :status => 404, :formats => 'html'}
      end
    end

    def render_404_invalid_format
      return if performed?
      render :file => "#{Rails.root}/public/404", :formats => [:html]
    end

    def render_500
      Rails.logger.fatal("please confirm that the Solr is running.")
      return if performed?
      #flash[:notice] = t('page.connection_failed')
      respond_to do |format|
        format.html {render :file => "#{Rails.root.to_s}/public/500", :layout => false, :status => 500}
        #format.mobile {render :file => "#{Rails.root.to_s}/public/500", :layout => false, :status => 500}
        format.xml {render :template => 'page/500', :status => 500}
        format.json { render :text => '{"error": "server_error"}' }
      end
    end

    def set_locale
      if params[:locale]
        unless I18n.available_locales.include?(params[:locale].to_s.intern)
          raise InvalidLocaleError
        end
      end
      if user_signed_in?
        locale = params[:locale] || session[:locale] || current_user.locale.try(:to_sym)
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
      {:locale => nil}
    end

    def set_available_languages
      @available_languages = Language.where(:iso_639_1 => I18n.available_locales.map{|l| l.to_s})
    end

    def set_mobile_request
      return if request.format != 'text/html'
      case params[:mobile_view]
      when 'true'
        request.variant = :phone
        session[:mobile_view] = true
      when 'false'
        session[:mobile_view] = false
      else
        browser = Browser.new(:ua => request.user_agent)
        if browser.mobile?
          if session[:mobile_view]
            request.variant = :phone
          else
            if session[:mobile_view].nil?
              request.variant = :phone
            end
          end
        end
      end
    end

    def reset_params_session
      session[:params] = nil
    end

    def not_found
      raise ActiveRecord::RecordNotFound
    end

    def access_denied
      render_403
    end

    def get_user
      @user = User.where(:username => params[:user_id]).first if params[:user_id]
      authorize @user, :show? if @user
    end

    def get_user_group
      @user_group = UserGroup.find(params[:user_group_id]) if params[:user_group_id]
    end

    def convert_charset
      case params[:format]
      when 'csv'
        return unless Setting.csv_charset_conversion
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

    def make_internal_query(search)
      # 内部的なクエリ
      set_role_query(current_user, search)

      unless params[:mode] == "add"
        agent = @agent
        manifestation = @manifestation
        reservable = @reservable
        carrier_type = params[:carrier_type]
        library = params[:library]
        language = params[:language]
        if defined?(EnjuSubject)
          subject = params[:subject]
          subject_by_term = Subject.where(:term => params[:subject]).first
          @subject_by_term = subject_by_term
        end

        search.build do
          with(:publisher_ids).equal_to agent.id if agent
          with(:original_manifestation_ids).equal_to manifestation.id if manifestation
          with(:reservable).equal_to reservable unless reservable.nil?
          unless carrier_type.blank?
            with(:carrier_type).equal_to carrier_type
          end
          unless library.blank?
            library_list = library.split.uniq
            library_list.each do |library|
              with(:library).equal_to library
            end
          end
          unless language.blank?
            language_list = language.split.uniq
            language_list.each do |language|
              with(:language).equal_to language
            end
          end
          if defined?(EnjuSubject)
            unless subject.blank?
              with(:subject).equal_to subject_by_term.term
            end
          end
        end
      end
      return search
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
        @news_feeds = Rails.cache.fetch('news_feed_all'){NewsFeed.all}
        @news_posts = NewsPost.limit(Setting.news_post.number.top_page)
      end
      @libraries = Library.real
    end

    def move_position(resource, direction, redirect = true)
      if ['higher', 'lower'].include?(direction)
        resource.send("move_#{direction}")
        if redirect
          redirect_to url_for(:controller => resource.class.to_s.pluralize.underscore)
          return
        end
      end
    end
  end

  class InvalidLocaleError < StandardError
  end
end

ActiveRecord::Base.send(:include, EnjuLeaf::EnjuUser)
ActionController::Base.send(:include, EnjuLeaf)
