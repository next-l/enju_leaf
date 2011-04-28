WillPaginate::ViewHelpers.pagination_options[:class] = "digg_pagination"

# https://gist.github.com/759937
class WillPaginateJqueryMobileRenderer < WillPaginate::ViewHelpers::LinkRenderer
  def container_attributes
    super.merge({:'data-role' => 'navbar'})
  end

  protected
  def pagination
    [:previous_page, current_page, :next_page]
  end

  def first_page
    previous_or_next_page(current_page == 1 ? nil : 1, @options[:first_label], "first_page")
  end

  def last_page
    previous_or_next_page(current_page == total_pages ? nil : total_pages, @options[:last_label], "last_page")
  end

  def previous_or_next_page(page, text, classname)
    if page
      '<li>' + link(text, page, :class => classname) + '</li>'
    else
      '<li>' + link('no page', page, :class => classname + ' disabled') + '</li>'
    end
  end

  def html_container(html)
    tag(:div, tag(:ul, html), container_attributes)
  end

  def page_number(page)
    tag(:li, link(page, page, :rel => rel_value(page)))
  end
end
