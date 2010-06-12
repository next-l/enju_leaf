module SearchHistoriesHelper
  def reverse_tag_cloud(query_and_numbers)
    return nil if query_and_numbers.nil?
    # TODO: add options to specify different limits and sorts
    #tags = Tag.all(:limit => 100, :order => 'taggings_count DESC').sort_by(&:name)
    
    # TODO: add option to specify which classes you want and overide this if you want?
    classes = %w(popular v-popular vv-popular vvv-popular vvvv-popular)
    
    max, min = 0, 0
    query_and_numbers.each do |query|
      #if options[:max] or options[:min]
      #  max = options[:max].to_i
      #  min = options[:min].to_i
      #end
      max = query[1] if query[1].to_i > max
      min = query[1] if query[1].to_i < min
    end
    divisor = ((max - min).div(classes.size)) + 1
    
    html =    %(<div class="hTagcloud">\n)
    html <<   %(  <ul class="popularity">\n)
    query_and_numbers.each do |query|
      html << %(  <li>)
      html << link_to(h(query[0]), manifestations_url(:query => query[0]), :class => classes[(query[1] - min).div(divisor)]) 
      html << %(  </li>\n) # FIXME: IEのために文末の空白を入れている
    end
    html <<   %(  </ul>\n)
    html <<   %(</div>\n)
  end

end
