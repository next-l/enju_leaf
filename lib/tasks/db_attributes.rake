# coding: utf-8
namespace :enju do
  namespace :db do
    desc 'print attributes'
    task :desc => :environment do
      format = ENV['format'] || "text"
      unless format == "text" || format == "excel" || format == "graph"
        STDERR.puts "format invalid. #{format}"
        STDERR.puts "format 'text' or 'excel' or 'graph' (default:'text')"
        raise
      end
      display_association = ENV['association'] || 'off'
      unless display_association == 'off' || display_association == 'on'
        STDERR.puts "association invalid. #{format}"
        STDERR.puts "association 'on' or 'off' (default:'off') "
        raise
      end

      target_models = ENV['models'].split(',') if ENV['models']

      CONST_COLUMN = {"created_at"=>I18n.t('page.created_at'),
        "updated_at"=>I18n.t('page.updated_at'),
        "id"=>'ID',
      }

      association_names = {:has_one=>"1:1", :has_many=>"1:N", :belongs_to=>"N:1"}
      association_vectors = {:has_one=>"<=>", :has_many=>"=>", :belongs_to=>"<="}
      association_macros = [:has_one, :has_many, :belongs_to]

      Dir.glob(Rails.root.join('app/models/**/*.rb')).each { |path| require path }
      tables = ActiveRecord::Base.connection.tables.sort
      models = tables.map{|table| Object.const_get(table.classify) rescue nil}.compact

      if target_models.blank?
        target_models = models.inject([]) {|a, b| a << b.to_s.downcase }
      end
      if target_models.present?
        STDERR.puts "target_models=#{target_models}"
      end

      case format
      when "excel"
        require 'axlsx'
       
        Axlsx::Package.new do |pkg|
          wb = pkg.workbook

          sty = wb.styles.add_style :font_name => Setting.manifestation_list_print_excelx.fontname
          wh_cell = wb.styles.add_style :border => { :style => :thin, :color => "00" },
						:font_name => Setting.manifestation_list_print_excelx.fontname
					gray_cell = wb.styles.add_style :bg_color => "aa",
						:border => { :style => :thin, :color => "00" },
						:font_name => Setting.manifestation_list_print_excelx.fontname

          wb.add_worksheet(:name => "DB Shemes") do |sheet|
            models.each do |model|
              next unless target_models.include?(model.to_s.downcase)
              #puts "aaa model=#{model.to_s.downcase}"

              sheet.add_row ["#{model.to_s}", "#{model.table_name}", I18n.t("activerecord.models.#{model.to_s.underscore}")], :types => :string, :style => [sty, sty, sty]

              sheet.add_row ["アトリビュート名","型","型","名称"], :style => [gray_cell, gray_cell, gray_cell, gray_cell]
              model.columns.each do |column|
                cols = [column.name, column.type, column.sql_type]
                msg = I18n.t("activerecord.attributes.#{model.to_s.underscore}.#{column.name}")
                if msg.index("translation missing:") == 0
                  msg = CONST_COLUMN[column.name]
                  if msg.blank?
                    if column.name.match("(.*)_id$")
                      msg = I18n.t("activerecord.models.#{$1}") + " ID"
                    end
                  end
                end
                cols << msg
                sheet.add_row cols, :types => :string, :style => [wh_cell, wh_cell, wh_cell, wh_cell]
              end

              if display_association == 'on'
                # table index
                sheet.add_row []
                sheet.add_row ["database indexes"], :style => [gray_cell, gray_cell]
                sheet.add_row ["pk", "#{ActiveRecord::Base.connection.primary_key(model.table_name)}"], :types => :string, :style => [wh_cell, wh_cell]
                ActiveRecord::Base.connection.indexes(model.table_name).each_with_index do |index, i|
                  sheet.add_row ["#{i+1}", "#{index.name}", "#{index.columns.join(',')}"], :types => :string, :style => [wh_cell, wh_cell, wh_cell]
                end

                # associations
                association_macros.each do |macro|
                  sheet.add_row []
                  sheet.add_row ["association", "#{association_names[macro]}"], :types => :string, :style => [gray_cell, gray_cell]
                  begin
                    model.reflect_on_all_associations(macro).each_with_index do |r, i|
                      sheet.add_row ["#{i+1}", "#{r.association_foreign_key}", "#{r.table_name}", "#{r.association_primary_key}"], :types => :string, :style => [wh_cell, wh_cell, wh_cell, wh_cell]

                    end
                  rescue 
                    puts "error(#{$!})"
                    #puts $@
                  end
                end
              end
							sheet.add_row []
            end
          end
          pkg.serialize('enju_db_schema.xlsx')
        end

      when "graph"
        # gem install ruby-graphviz
        require 'graphviz'
        # Create a new graph
        g = GraphViz.new( :G, :type => :digraph )
        nodes = {}

        models.each do |model|
          next unless target_models.include?(model.to_s.downcase)

          # Create two nodes
          nodes[model.to_s.downcase] = g.add_nodes("#{model.to_s}")

        end 

        models.each do |model|
          next unless target_models.include?(model.to_s.downcase)

#      association_names = {:has_one=>"1:1", :has_many=>"1:N", :belongs_to=>"N:1"}
#      association_vectors = {:has_one=>"<=>", :has_many=>"=>", :belongs_to=>"<="}
#      association_macros = [:has_one, :has_many, :belongs_to]

          # associations
          association_macros.each do |macro|
            #sheet.add_row ["association", "#{association_names[macro]}"], :types => :string, :style => [gray_cell, gray_cell]
            begin
              model.reflect_on_all_associations(macro).each_with_index do |r, i|
                #sheet.add_row ["#{i+1}", "#{r.association_foreign_key}", "#{r.table_name}", "#{r.association_primary_key}"], :types => :string, :style => [wh_cell, wh_cell, wh_cell, wh_cell]
                node1_name = model.to_s.downcase
                node2_name = r.name.to_s.singularize.camelize.downcase
                STDERR.puts r.inspect
                STDERR.puts "node1_name=#{node1_name}"
                STDERR.puts "node2_name=#{node2_name}"
                node1 = nodes[node1_name]
                node2 = nodes[node2_name]
                # Create an edge between the two nodes
                g.add_edges( node1, node2 )
              end
            rescue 
              STDERR.puts "error(#{$!})"
              STDERR.puts $@
              #raise
            end
          end
        end 
        if nodes.size > 0
          # Generate output image
          g.output( :png => "enju_db_schema.png" )
        end
      else
        models.each do |model|
          puts ""
          puts "======="
          print "Model=#{model.to_s} "
          print "Table=#{model.table_name} "
          print I18n.t("activerecord.models.#{model.to_s.underscore}")
          puts ""
          puts ""
          model.columns.each { |column|
            print sprintf("|%s|%s|%s|", column.name, column.type, column.sql_type)
            msg = I18n.t("activerecord.attributes.#{model.to_s.underscore}.#{column.name}")
            if msg.index("translation missing:") == 0
              msg = CONST_COLUMN[column.name]
              if msg.blank?
                if column.name.match("(.*)_id$")
                  msg = I18n.t("activerecord.models.#{$1}") + " ID"
                end
              end
            end
            print msg
            puts ""
          }
          # table index
          puts ""
          puts "database indexes: "
          puts ""
          #puts ActiveRecord::Base.connection.indexes(model.table_name).inspect
          puts "pk : #{ActiveRecord::Base.connection.primary_key(model.table_name)}"
          ActiveRecord::Base.connection.indexes(model.table_name).each_with_index do |index, i|
            puts "#{i+1} : #{index.name} columns=#{index.columns.join(',')}"
          end

          # associations
          association_macros.each do |macro|
            puts ""
            puts "association: #{association_names[macro]}"
            puts ""
            begin
              model.reflect_on_all_associations(macro).each_with_index do |r, i|
                #puts "#{i+1} #{r.name} #{r.class_name} #{r.table_name} #{r.association_primary_key} #{r.association_foreign_key}"
                puts "#{i+1} : #{r.association_foreign_key} #{association_vectors[macro]} #{r.table_name} #{r.association_primary_key} "

              end
            rescue 
              STDERR.puts "error(#{$!})"
              #puts $@
            end
          end
        end
      end
    end
  end
end
