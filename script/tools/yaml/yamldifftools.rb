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

class CompareYaml
  @num_of_hierarchy = 1

  def self.insert_hashes(hashes, insert_point, insert_hashes)
		#STDERR.puts "insert hash keys=#{insert_point.join('.')} "
		#TODO
		p = hashes
		insert_point.each_with_index do |key, i|
			if i == (insert_point.size - 1)
				# leaf point
				#STDERR.puts "key=#{key} h=#{insert_hashes}"
				#STDERR.puts p
				p[key] = insert_hashes
			else
				if i + 1 <= @num_of_hierarchy
					#STDERR.puts "skip."
					#TODO
					index = 0
          yaml1keys = p.keys
          key = yaml1keys[index]
					p = p[key]
				else
					if p.has_key?(key)
						p = p[key]	
					else
						STDERR.puts "error inser_point=#{insert_point} key=#{key}"
						raise
					end
				end
			end
		end
	end

  def self.compare_hashes(yaml1, yaml2, options = {:level => 1, :parentkeys => []})
    level = options[:level]
    parentkeys = options[:parentkeys]

    index = 0
    yaml2.each do |key, value|
      if level <= @num_of_hierarchy
        # 無視する
        if value.is_a?(Hash)
          #STDERR.puts "level=#{level} index=#{index} key=#{key} value=@@@Hash@@@"
          yaml1keys = yaml1.keys
          key1 = yaml1keys[index]

          keys = parentkeys.dup
          keys << key
          compare_hashes(yaml1[key1], yaml2[key], {:level => level+1, :parentkeys => keys})
          next
        end
      end

      unless yaml1
        STDERR.puts "error yaml1 is empty key=#{key}"
				STDERR.puts parentkeys
				raise
        #next
      end

      unless yaml1.has_key?(key)
				#STDERR.puts "index=#{index}"
        keys = parentkeys.dup
				keys << key
				#STDERR.puts "error yaml1 not find key. key=#{key} keys=#{parentkeys.join('.')}"
				insert_hashes($org_yaml, keys, value)
				next
			end

      value1 = yaml1[key] 
      unless value1 
				#STDERR.puts "index=#{index}"
        keys = parentkeys.dup
				keys << key
				#STDERR.puts "error yaml1 not find key. key=#{key} keys=#{parentkeys.join('.')}"
				insert_hashes($org_yaml, keys, value)
				next
			end

			#STDERR.puts "level=#{level} index=#{index} key=#{key} value=#{value.class}  keys=#{parentkeys.join('.')}"
=begin
			if key == "reserve_stat_has_manifestation"
				STDERR.puts "key=#{key} value1=#{value1}"
			end
=end

      if value.is_a?(Hash)
        keys = parentkeys.dup
        keys << key
				#STDERR.puts "b1 #{keys}"
        compare_hashes(yaml1[key], yaml2[key], {:level => level+1, :parentkeys => keys})
        next
      end

      #STDERR.puts "level=#{level} index=#{index} key=#{key} value=#{value.class}  keys=#{parentkeys.join('.')}"
      index = index + 1
    end
  end
end

CompareYaml.compare_hashes(yaml1, yaml2)
puts $org_yaml.to_yaml
