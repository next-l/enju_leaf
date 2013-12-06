require "enju_trunk/engine"
require "enju_trunk/version"
require "enju_trunk/string_strip_tag"
require "enju_trunk/notification_sounds"
require "enju_trunk/localized_name"
require "geocoder"
require "client_side_validations"
require "acts-as-taggable-on"
require "ipaddr"
require "pp"

module EnjuTrunk
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def enju_trunk
      include EnjuTrunk::InstanceMethods
    end
  end

  module InstanceMethods
    def add_breadcrumb name, url=''
      name = eval(name) unless name.blank?
      url = eval(url) if !url.blank? && url =~ /_path|_url|@|session/
      while session[:breadcrumbs] && session[:breadcrumbs].key?(name)
        session[:breadcrumbs].delete(session[:breadcrumbs].to_a.last.first)
      end
      session[:breadcrumbs] = {I18n.t('breadcrumb.lib_top') => root_path} if session[:breadcrumbs].nil? || session[:breadcrumbs].empty?
      session[:breadcrumbs].store(name, url) unless name.blank?
    end

    def self.add_breadcrumb name, url, options = {}
      before_filter options do |controller|
        controller.send(:add_breadcrumb, name, url)
      end
    end

    def clear_breadcrumbs
      session[:breadcrumbs].clear if session[:breadcrumbs]
    end

    def self.clear_breadcrumbs options = {}
      before_filter options do |controller|
        controller.send(:clear_breadcrumbs)
      end
    end

    private
    def render_404
      return if performed?
		  logger.warn $@
		  logger.warn $!

      respond_to do |format|
        format.html {render :template => 'page/404', :status => 404}
        format.mobile {render :template => 'page/404', :status => 404}
        format.xml {render :template => 'page/404', :status => 404}
        format.json
      end
    end

    def render_500
      return if performed?
		  logger.warn $@
		  logger.warn $!

      #flash[:notice] = t('page.connection_failed')
      respond_to do |format|
        format.html {render :file => "#{Rails.root.to_s}/public/500.html", :layout => false, :status => 500}
        format.mobile {render :file => "#{Rails.root.to_s}/public/500.html", :layout => false, :status => 500}
      end
    end

    def render_500_solr
      return if performed?
      #flash[:notice] = t('page.connection_failed')

		  logger.warn $@
		  logger.warn $!

      respond_to do |format|
        format.html {render :template => 'page/500', :status => 500}
        format.mobile {render :template => 'page/500', :status => 500}
        format.xml {render :template => 'page/500', :status => 500}
        format.json
      end
    end

    def set_current_user
      if user_signed_in?
        User.current_user = current_user
      end
    end

    def get_library_group
      @library_group = LibraryGroup.site_config
    end

    def default_url_options(options={})
      {:locale => nil}
    end

    def reset_params_session
      session[:params] = nil
    end

    def get_real_libraries
      @libraries = Library.real.all
    end

    def get_bookstore
      @bookstore = Bookstore.find(params[:bookstore_id]) if params[:bookstore_id]
    end

    def get_reserve_states
      @reserve_states = Reserve.states
    end

    def get_reserve_information_types
      @reserve_information_types = Reserve.information_type_ids
    end

    def get_bookbinding
      @bookbinding = Bookbinding.find(params[:bookbinding_id]) if params[:bookbinding_id]
    end
 
    def get_current_basket
      @current_basket = current_user.current_basket if current_user
    end

    def my_networks?
      return true if LibraryGroup.site_config.network_access_allowed?(request.remote_ip, :network_type => 'lan')
      false
    end

    def admin_networks?
      return true if LibraryGroup.site_config.network_access_allowed?(request.remote_ip, :network_type => 'admin')
      false
    end

    def check_dsbl
      library_group = LibraryGroup.site_config
      return true if library_group.network_access_allowed?(request.remote_ip, :network_type => 'lan')
      begin
        dsbl_hosts = library_group.dsbl_list.split.compact
        reversed_address = request.remote_ip.split(/\./).reverse.join(".")
        dsbl_hosts.each do |dsbl_host|
          result = Socket.gethostbyname("#{reversed_address}.#{dsbl_host}.").last.unpack("C4").join(".")
          raise SocketError unless result =~ /^127\.0\.0\./
          access_denied
        end
      rescue SocketError
        nil
      end
    end

    def store_page
      flash[:page] = params[:page].to_i if params[:page]
    end

    def check_librarian
      access_denied unless current_user && current_user.has_role?('Librarian')
    end

    def get_top_page_content
      if defined?(EnjuNews)
        @news_feeds = Rails.cache.fetch('news_feed_all'){NewsFeed.all}
        @news_posts = NewsPost.limit(3)
      end
      @libraries = Library.real
    end

    def append_info_to_payload(payload)
      super
      payload[:current_user] = current_user rescue nil
      payload[:session_id] = request.session_options[:id] rescue nil
      payload[:remote_ip] = request.remote_ip
    end

    def get_manifestation_types
      @manifestation_types = ManifestationType.all
    end

    def get_carrier_types
      @carrier_types = CarrierType.all
    end
  end
end

ActionController::Base.send(:include, EnjuTrunk)
