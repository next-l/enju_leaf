module EnjuLeaf
  module EnjuLeafHelper
    def database_adapter
      case ActiveRecord::Base.connection.adapter_name
      when 'PostgreSQL'
        link_to 'PostgreSQL', 'http://www.postgresql.org/'
      when 'MySQL'
        link_to 'MySQL', 'http://www.mysql.org/'
      when 'SQLite'
        link_to 'SQLite', 'http://www.sqlite.org/'
      end
    end
  
    def title_action_name
      case controller.action_name
      when 'index'
        t('title.index')
      when 'show'
        t('title.show')
      when 'new'
        t('title.new')
      when 'edit'
        t('title.edit')
      end
    end
  
    def link_to_wikipedia(string)
      link_to "Wikipedia", "http://#{I18n.locale}.wikipedia.org/wiki/#{URI.escape(string)}"
    end
  
    def locale_display_name(locale)
      Language.where(:iso_639_1 => locale).first.display_name
    end
  
    def locale_native_name(locale)
      Language.where(:iso_639_1 => locale).first.native_name
    end
  
    def move_position(object)
      render :partial => 'page/position', :locals => {:object => object}
    end
  
    def localized_state(state)
      case state
      when 'pending'
        t('state.pending')
      when 'canceled'
        t('state.canceled')
      when 'started'
        t('state.started')
      when 'failed'
        t('state.failed')
      when 'completed'
        t('state.completed')
      else
        state
      end
    end
  
    def localized_boolean(bool)
      case bool.to_s
      when nil
      when "true"
        t('page.boolean.true')
      when "false"
        t('page.boolean.false')
      end
    end
  
    def current_user_role_name
      current_user.try(:role).try(:name) || 'Guest'
    end
  
    def title(controller_name)
      string = ''
      unless ['page', 'routing_error', 'my_accounts'].include?(controller_name)
        string << t("activerecord.models.#{controller_name.singularize}") + ' - '
      end
      if controller_name == 'routing_error'
        string << t("page.routing_error") + ' - '
      end
      string << LibraryGroup.system_name + ' - Next-L Enju Leaf'
      string.html_safe
    end
  
    def back_to_index(options = {})
      if options == nil
        options = {}
      else
        options.reject!{|key, value| value.blank?}
        options.delete(:page) if options[:page].to_i == 1
      end
      unless controller_name == 'test'
        link_to t('page.listing', :model => t("activerecord.models.#{controller_name.singularize}")), url_for(params.merge(:controller => controller_name, :action => :index, :id => nil, :only_path => true).merge(options))
      end
    end
  
    def set_focus_on_search_form
      javascript_tag("$(function(){$('#search_form').focus()})") if @query.blank?
    end
  
    def markdown_helper(string)
      return unless string
      if defined?(JRUBY_VERSION)
        string
      #  Kramdown::Document.new(string.to_s).to_html.html_safe
      else
        markdown = Redcarpet::Markdown.new(
          Redcarpet::Render::HTML,
          :autolink => true, :safe_links_only => true
        )
        markdown.render(string.to_s).html_safe
      end
    end
  end
end
