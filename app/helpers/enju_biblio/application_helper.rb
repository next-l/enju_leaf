module EnjuBiblio
  module ApplicationHelper
    def form_icon(carrier_type)
      unless carrier_type
        return image_tag('icons/help.png', size: '16x16', class: 'enju_icon', alt: t('page.unknown'))
      end

      if carrier_type.attachment.attached?
        image_tag(carrier_type.attachment.representation(resize_to_limit: [16, 16]), size: '16x16', class: 'enju_icon', alt: carrier_type.display_name.localize)
      else
        image_tag('icons/help.png', size: '16x16', class: 'enju_icon', alt: t('page.unknown'))
      end
    end

    def content_type_icon(content_type)
      case content_type.name
      when 'text'
        image_tag('icons/page_white_text.png', size: '16x16', class: 'enju_icon', alt: content_type.display_name.localize)
      when 'still_image'
        image_tag('icons/picture.png', size: '16x16', class: 'enju_icon', alt: content_type.display_name.localize)
      when 'sounds'
        image_tag('icons/sound.png', size: '16x16', class: 'enju_icon', alt: content_type.display_name.localize)
      when 'two_dimensional_moving_image'
        image_tag('icons/film.png', size: '16x16', class: 'enju_icon', alt: content_type.display_name.localize)
      else
        image_tag('icons/help.png', size: '16x16', class: 'enju_icon', alt: t('page.unknown'))
      end
    rescue NoMethodError
      image_tag('icons/help.png', size: '16x16', class: 'enju_icon', alt: t('page.unknown'))
    end

    def agent_type_icon(agent_type)
      case agent_type
      when 'person'
        image_tag('icons/user.png', size: '16x16', class: 'enju_icon', alt: 'Person')
      when 'corporate_body'
        image_tag('icons/group.png', size: '16x16', class: 'enju_icon', alt: 'CorporateBody')
      else
        image_tag('icons/help.png', size: '16x16', class: 'enju_icon', alt: t('page.unknown'))
      end
    end

    def agents_list(authors, options = {})
      list = []
      if options[:nolink]
        return authors.pluck(:name)
      else
        list = authors.map{|author| link_to(author.name, manifestations_path(query: "\"#{author.name}\""), options)}
        list.join(" ").html_safe
      end
    end

    def identifier_link(identifier)
      case identifier.identifier_type.name
      when 'doi'
        link_to identifier.body, "https://doi.org/#{identifier.body}"
      when 'iss_itemno'
        link_to identifier.body, "https://iss.ndl.go.jp/books/#{identifier.body}"
      when 'lccn'
        link_to identifier.body, "https://lccn.loc.gov/#{identifier.body}"
      when 'ncid'
        link_to identifier.body, "https://ci.nii.ac.jp/ncid/#{identifier.body}"
      when 'isbn'
        Lisbn.new(identifier.body).isbn_with_dash
      else
        identifier.body
      end
    end
  end
end
