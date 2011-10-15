# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include PictureFilesHelper
  include EnjuBookJacketHelper

  def form_icon(carrier_type)
    case carrier_type.name
    when 'print'
      image_tag('icons/book.png', :size => '16x16', :alt => carrier_type.display_name.localize)
    when 'CD'
      image_tag('icons/cd.png', :size => '16x16', :alt => carrier_type.display_name.localize)
    when 'DVD'
      image_tag('icons/dvd.png', :size => '16x16', :alt => carrier_type.display_name.localize)
    when 'file'
      image_tag('icons/monitor.png', :size => '16x16', :alt => carrier_type.display_name.localize)
    else
      image_tag('icons/help.png', :size => '16x16', :alt => 'unknown')
    end
  rescue NoMethodError
    image_tag('icons/help.png', :size => '16x16', :alt => 'unknown')
  end

  def content_type_icon(content_type)
    case content_type.name
    when 'text'
      image_tag('icons/page_white_text.png', :size => '16x16', :alt => content_type.display_name.localize)
    when 'picture'
      image_tag('icons/picture.png', :size => '16x16', :alt => content_type.display_name.localize)
    when 'sound'
      image_tag('icons/sound.png', :size => '16x16', :alt => content_type.display_name.localize)
    when 'video'
      image_tag('icons/film.png', :size => '16x16', :alt => content_type.display_name.localize)
    else
      image_tag('icons/help.png', :size => '16x16', :alt => ('unknown'))
    end
  rescue NoMethodError
    image_tag('icons/help.png', :size => '16x16', :alt => ('unknown'))
  end

  def patron_type_icon(patron_type)
    case patron_type
    when 'Person'
      image_tag('icons/user.png', :size => '16x16', :alt => ('Person'))
    when 'CorporateBody'
      image_tag('icons/group.png', :size => '16x16', :alt => ('CorporateBody'))
    else
      image_tag('icons/help.png', :size => '16x16', :alt => ('unknown'))
    end
  end

  def link_to_tag(tag)
    link_to tag, manifestations_path(:tag => tag.name)
  end

  def render_tag_cloud(tags, options = {})
    return nil if tags.nil?
    # TODO: add options to specify different limits and sorts
    #tags = Tag.all(:limit => 100, :order => 'taggings_count DESC').sort_by(&:name)

    # TODO: add option to specify which classes you want and overide this if you want?
    classes = %w(popular v-popular vv-popular vvv-popular vvvv-popular)

    max, min = 0, 0
    tags.each do |tag|
      #if options[:max] or options[:min]
      #  max = options[:max].to_i
      #  min = options[:min].to_i
      #end
      max = tag.taggings.size if tag.taggings.size > max
      min = tag.taggings.size if tag.taggings.size < min
    end
    divisor = ((max - min).div(classes.size)) + 1

    html =    %(<div class="hTagcloud">\n)
    html <<   %(  <ul class="popularity">\n)
    tags.each do |tag|
      html << %(  <li>)
      html << link_to(tag.name, manifestations_path(:tag => tag.name), :class => classes[(tag.taggings.size - min).div(divisor)])
      html << %(  </li>\n) # FIXME: IEのために文末の空白を入れている
    end
    html <<   %(  </ul>\n)
    html <<   %(</div>\n)
    html.html_safe
  end

  def patrons_list(patrons = [], options = {})
    return nil if patrons.blank?
    patrons_list = []
    if options[:nolink]
      patrons_list = patrons.map{|patron| patron.full_name}
    else
      patrons_list = patrons.map{|patron| link_to(patron.full_name, patron, options)}
    end
    patrons_list.join(" ").html_safe
  end

  def book_jacket(manifestation)
    if manifestation.picture_files.exists?
      link = ''
      manifestation.picture_files.each_with_index do |picture_file, i|
        if i == 0
          link += link_to(show_image(picture_file, :size => :thumb), picture_file_path(picture_file, :format => picture_file.extname), :rel => "manifestation_#{manifestation.id}")
        else
          link += '<span style="display: none">' + link_to(show_image(picture_file, :size => :thumb), picture_file_path(picture_file, :format => picture_file.extname), :rel => "manifestation_#{manifestation.id}") + '</span>'
        end
      end
      return link.html_safe
    else
      link = book_jacket_tag(manifestation)
      unless link
        link = screenshot_tag(manifestation)
      end
    end

    unless link
      link = link_to image_tag('unknown_resource.png', :width => '100', :height => '100', :alt => '*', :itemprop => 'image'), manifestation
    end
    link
  #rescue NoMethodError
  #  nil
  end

  def database_adapter
    case ActiveRecord::Base.configurations["#{Rails.env}"]['adapter']
    when 'postgresql'
      link_to 'PostgreSQL', 'http://www.postgresql.org/'
    when 'jdbcpostgresql'
      link_to 'PostgreSQL', 'http://www.postgresql.org/'
    when 'mysql'
      link_to 'MySQL', 'http://www.mysql.org/'
    when 'jdbcmysql'
      link_to 'MySQL', 'http://www.mysql.org/'
    when 'sqlite3'
      link_to 'SQLite', 'http://www.sqlite.org/'
    when 'jdbcsqlite3'
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
      link_to t('page.listing', :model => t("activerecord.models.#{controller_name.singularize}")), url_for(params.merge(:controller => controller_name, :action => :index, :id => nil).merge(options))
    end
  end

  def set_focus_on_search_form
    javascript_tag("$('#search_form').focus()") if @query.blank?
  end
end
