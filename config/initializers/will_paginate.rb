WillPaginate::ViewHelpers.pagination_options[:class] = "digg_pagination"

# https://gist.github.com/759937
class WillPaginateJqueryMobileRenderer < WillPaginate::ViewHelpers::LinkRenderer
  def container_attributes
    super.merge({ 
      :'data-role' => 'navbar'
    })
  end

  def pagination
    @options[:page_links] ? windowed_page_numbers : []
  end

  protected

  def html_container(html)
    tag(:div, tag(:ul, html), container_attributes)
  end

  def windowed_page_numbers
    inner_window = 2

    left  = [ total_pages - inner_window * 2, current_page - inner_window ].min
    left  = [ left, 1 ].max
    right = [ left + inner_window * 2, total_pages ].min

    (left..right).to_a
  end

  def page_number(page)
    first = (page - 1) * @collection.per_page + 1
    last  = [ first + @collection.per_page - 1, @collection.total_entries ].min
    range = "#{first}-#{last}"

    c = (page == current_page) ? 'ui-btn-active' : nil

    tag(:li, link(range, page, :rel => rel_value(page), :class => c))
  end
end
