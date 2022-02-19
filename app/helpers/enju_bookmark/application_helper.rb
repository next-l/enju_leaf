module EnjuBookmark
  module ApplicationHelper
    def link_to_tag(tag)
      link_to tag, manifestations_path(tag: tag.name)
    end

    def render_tag_cloud(tags, options = {})
      # TODO: add options to specify different limits and sorts
      # tags = Tag.all(:limit => 100, :order => 'taggings_count DESC').sort_by(&:name)

      # TODO: add option to specify which classes you want and overide this if you want?
      classes = %w(popular v-popular vv-popular vvv-popular vvvv-popular)

      max, min = 0, 0
      tags.each do |tag|
        # if options[:max] or options[:min]
        #  max = options[:max].to_i
        #  min = options[:min].to_i
        # end
        max = tag.taggings.size if tag.taggings.size > max
        min = tag.taggings.size if tag.taggings.size < min
      end
      divisor = ((max - min).div(classes.size)) + 1

      content_tag :div, class: "hTagcloud" do
        content_tag :ul, class: "popularity" do
          tags.collect do |tag|
            concat(content_tag :li, link_to(tag.name, manifestations_path(tag: tag.name), class: classes[(tag.taggings.size - min).div(divisor)]) + "\n")
          end
        end
      end
    end
  end
end
