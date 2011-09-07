require 'will_paginate/view_helpers/action_view'

# https://gist.github.com/759937
module JqueryMobileRenderer
  class WillPaginateJqueryMobileRenderer < WillPaginate::ActionView::LinkRenderer

    def to_html
      html = pagination.map do |item|
        item.is_a?(Fixnum) ?
          page_number(item) :
          tag(:li, send(item), :class => 'mobile_pagination')
      end.join(@options[:link_separator])

      @options[:container] ? html_container(html) : html
    end

    def container_attributes
      super.merge({
        :'data-role' => 'navbar'
      })
    end

    def pagination
      items = @options[:page_links] ? [current_page] : []
      items.unshift :previous_page
      items.push :next_page
    end

    protected
    def html_container(html)
      tag(:div, tag(:ul, html), container_attributes)
    end
    
    def page_number(page)
      first = (page - 1) * @collection.per_page + 1
      last  = [ first + @collection.per_page - 1, @collection.total_entries ].min
      range = "#{first}-#{last}"

      c = (page == current_page) ? 'ui-btn-active' : nil

      tag(:li, link(range, page, :rel => rel_value(page), :class => c), :class => 'mobile_pagination')
    end

    def previous_or_next_page(page, text, classname)
      if page
        link(text, page, :class => classname)
      #else
      #  tag(:span, text, :class => classname + ' disabled')
      end
    end
  end
end

module WillPaginate
  module ActionView
    include JqueryMobileRenderer
  end
end

module ActionView
  module CompiledTemplates
    include WillPaginate::ActionView
  end
end
