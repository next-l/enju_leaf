# -*- coding: utf-8 -*-
require 'optparse'

module NdlStatisticsScript
  class Error < RuntimeError; end
  class AlreadyExist < Error; end
  class InvalidTerm < Error; end
  class NotFound < Error; end

  module_function

  def run!(cmd_path, argv)
    option = parse_option!(cmd_path, argv)

    case option[:mode]
    when :noop
      ''
    when :calc
      calc_ndl_statistics(option)
    when :del
      del_ndl_statistics(option)
      ''
    when :list
      list_ndl_statistics(option)
    end
  end

  private
  module_function

  def parse_option!(cmd_path, argv)
    option = {}

    OptionParser.new do |o|
      o.banner = "使い方: #{cmd_path.sub(/\.rb\z/, '')} options term"
      o.separator ''

      o.separator 'オプション:'

      o.on('-c', '--calculate', '指定した年度の年報情報を集計する') do
        option[:mode] = :calc
      end

      o.on('-d', '--delete', '指定した年度の年報情報を削除する') do
        option[:mode] = :del
      end

      o.on('-l', '--list', '集計済の年報一覧を表示する') do
        option[:mode] = :list
      end

      o.separator ''
      o.on_tail('--help', 'この表示を行う') do
        option[:mode] = :noop
        puts o
      end
    end.parse!(argv)

    case option[:mode]
    when nil
      raise OptionParser::InvalidOption,
        'オプション指定が必要です'
    when :calc, :del
      if argv.blank?
        raise OptionParser::InvalidOption,
          '年度の指定が必要です(平成NN年度)'
      end
      option[:term] = argv.shift
    end

    option
  end

  def calc_ndl_statistics(option)
    unless Term.where(:display_name => "平成#{option[:term]}年度").exists?
      raise InvalidTerm
    end
    term_id = Term.where(:display_name => "平成#{option[:term]}年度").first.id

    if NdlStatistic.where(:term_id => term_id).exists?
      raise AlreadyExist
    end
    NdlStatistic.create!(:term_id => term_id).calc_all
  end

  def del_ndl_statistics(option)
    unless Term.where(:display_name => "平成#{option[:term]}年度").exists?
      raise InvalidTerm
    end
    term_id = Term.where(:display_name => "平成#{option[:term]}年度").first.id

    unless NdlStatistic.where(:term_id => term_id).exists?
      raise NotFound
    end

    NdlStatistic.where(:term_id => term_id).destroy_all
  end

  def list_ndl_statistics(option)
    ndl_statistics = NdlStatistic.all
    if ndl_statistics.count == 0
      raise NotFound
    end
    list = "集計済の支部図書館業務年報:\n"
    ndl_statistics.each do |ndl_statistic|
      term_name = Term.where(:id => ndl_statistic.term_id).first.display_name
      list << "  #{term_name}\n"
    end
    list
  end
end

if $0 == __FILE__
  begin
    ARGV.shift if ARGV.first == '--' # NOTE: rails runnerのコマンドライン引数のクセを回避するための処置
    output = NdlStatisticsScript.run!($0, ARGV)
#    puts output.chomp unless output.blank?
    puts output unless output.blank?
  rescue NdlStatisticsScript::InvalidTerm
    abort '不正な年度です'
  rescue NdlStatisticsScript::AlreadyExist
    abort 'レポートは集計済みです'
  rescue NdlStatisticsScript::NotFound
    abort 'レポートは集計されていません'
  rescue OptionParser::ParseError, NdlStatisticsScript::Error
    abort $!.message
  end
end

