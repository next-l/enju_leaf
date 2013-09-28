#!/usr/bin/env ruby
# coding: UTF-8

require 'yaml'
require 'optparse'

# 引数を解析する
unless ARGV.size == 2
  STDERR.puts("missing operand after #{$0}")
  STDERR.puts("usage: #{$0} yamlfile1 yamlfile2")
  exit(1)
end

yaml1 = YAML.load_file(ARGV[0])
yaml2 = YAML.load_file(ARGV[1])

#TODO
$org_yaml = YAML.load_file(ARGV[0])
$gen_yaml = {}

class CompareYaml
  @num_of_hierarchy = 1

  def self.insert_hashes(hashes, insert_point, insert_hashes)
		#puts "keys=#{insert_point.join('.')} value=#{insert_hashes}"
		puts "insert hash keys=#{insert_point.join('.')} "
	end

  def self.compare_hashes(yaml1, yaml2, options = {:level => 1, :parentkeys => []})
    errors = []
    level = options[:level]
    parentkeys = options[:parentkeys]

    index = 0
    yaml2.each do |key, value|
      if level <= @num_of_hierarchy
        # 無視する
        if value.is_a?(Hash)
          #puts "level=#{level} index=#{index} key=#{key} value=@@@Hash@@@"
          yaml1keys = yaml1.keys
          key1 = yaml1keys[index]

          keys = parentkeys.dup
          keys << key
          errors << compare_hashes(yaml1[key1], yaml2[key], {:level => level+1, :parentkeys => keys})
          next
        end
      end

      unless yaml1
        puts "error yaml1 is empty"
        next
      end

      unless yaml1.has_key?(key)
				puts "index=#{index}"
        keys = parentkeys.dup
				keys << key
				#puts "error yaml1 not find key. key=#{key} keys=#{parentkeys.join('.')}"
				insert_hashes($org_yaml, keys, value)
				next
			end

      value1 = yaml1[key] 

      if (value.class != value1.class)
        keys = parentkeys.dup
        keys << key
        #puts "error yaml1 another class. key=#{key} keys=#{parentkeys.join('.')}"
				insert_hashes($org_yaml, keys, value)
        next
      end

			#puts "level=#{level} index=#{index} key=#{key} value=#{value.class}  keys=#{parentkeys.join('.')}"

      if value.is_a?(Hash)
        keys = parentkeys.dup
        keys << key
				#puts "b1 #{keys}"
        errors << compare_hashes(yaml1[key], yaml2[key], {:level => level+1, :parentkeys => keys})
        next
      end

      #puts "level=#{level} index=#{index} key=#{key} value=#{value.class}  keys=#{parentkeys.join('.')}"
      index = index + 1
    end

    errors
  end
end

result = CompareYaml.compare_hashes(yaml1, yaml2)
puts result

