require "webpacker/helper"

module EnjuLeaf
  module ApplicationHelper
    # HTMLのtitleに表示されるアクション名を設定します。
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
      Language.where(iso_639_1: locale).first.display_name
    end

    def locale_native_name(locale)
      Language.where(iso_639_1: locale).first.native_name
    end

    def move_position(object)
      render partial: 'page/position', locals: {object: object}
    end

    # I18nに対応した状態名を表示します。
    # @param [String] state 状態名
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

    # I18nに対応した状態名を表示します。
    # @param [Boolean] bool 状態名
    def localized_boolean(bool)
      case bool.to_s
      when nil
      when "true"
        t('page.boolean.true')
      when "false"
        t('page.boolean.false')
      end
    end

    # ログイン中のユーザの権限名を表示します。
    def current_user_role_name
      current_user.try(:role).try(:name) || 'Guest'
    end

    # HTMLのtitleを表示します。
    def title(controller_name, model_name = controller_name&.singularize)
      string = ''
      unless ['page', 'routing_error', 'my_accounts'].include?(controller_name)
        string << t("activerecord.models.#{model_name}") + ' - '
      end
      if controller_name == 'routing_error'
        string << t("page.routing_error") + ' - '
      end
      string << LibraryGroup.system_name + ' - Next-L Enju Leaf'
      string.html_safe
    end

    # 前の画面に戻るリンクを表示します。
    # @param [Hash] options
    def back_to_index(options = {})
      if options.nil?
        options = {}
      else
        options.reject!{|_key, value| value.blank?}
        options.delete(:page) if options[:page].to_i == 1
      end
      link_to t('page.listing', model: t("activerecord.models.#{controller_name&.singularize}")), url_for(request.params.merge(controller: controller_name, action: :index, page: nil, id: nil, only_path: true).merge(options))
    end

    # 検索フォームにフォーカスを移動するJavaScriptを表示します。
    def set_focus_on_search_form
      javascript_tag("$(function(){$('#search_form').focus()})") if @query.blank?
    end

    # Markdownの文字列をパースして表示します。
    # @param [String] string Markdownの文字列
    def markdown_helper(string)
      return unless string
      Kramdown::Document.new(string.to_s).to_html.html_safe
    end

    # ユーザの未読メッセージ数を表示します。
    # @param [User] user ユーザ
    def messages_count(user)
      Message.search do
        with(:receiver_id).equal_to user.id
        with(:is_read).equal_to false
      end.hits.total_entries
    end

    def current_language
      Language.find_by(iso_639_1: @locale) || Language.order(:position).first
    end
  end
end
