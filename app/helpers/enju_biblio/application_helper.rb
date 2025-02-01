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

    def agents_list(agents = [], options = {})
      return nil if agents.blank?

      agents_list = []
      if options[:nolink]
        agents_list = agents.map{|agent| agent.full_name}
      else
        agents_list = agents.map{|agent|
          link_to(agent.full_name, manifestations_path(query: "\"#{agent.full_name}\""), options) + ' ' + (link_to("[A]", agent_path(agent)) if agent.ndla_record)
        }
      end
      agents_list.join(" ").html_safe
    end

    def ndl_bib_id_record_link(ndl_bib_id_record)
      if ndl_bib_id_record.body =~ /\AR[0-9A-Za-z]+?-I[0-9A-Za-z]+?-00\z/
        link_to ndl_bib_id_record.body, "https://iss.ndl.go.jp/books/#{ndl_bib_id_record.body}"
      else
        link_to ndl_bib_id_record.body, "https://ndlsearch.ndl.go.jp/books/#{ndl_bib_id_record.body}"
      end
    end

    def identifier_link(identifier)
      identifier.body
    end
  end
end
