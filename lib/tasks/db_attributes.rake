namespace :enju do
  namespace :db do
    desc 'print attributes'
    task :desc => :environment do
      format = ENV['format'] || "text"
      unless format == "text" || format == "excel"
        STDERR.puts "format invalid. #{format}"
        raise
      end

      CONST_COLUMN = {"created_at"=>I18n.t('page.created_at'),
        "updated_at"=>I18n.t('page.updated_at'),
        "id"=>'ID',
      }

      association_names = {:has_one=>"1:1", :has_many=>"1:N", :belongs_to=>"N:1"}
      association_vectors = {:has_one=>"<=>", :has_many=>"=>", :belongs_to=>"<="}
      association_macros = [:has_one, :has_many, :belongs_to]

      Dir.glob(Rails.root.join('app/models/**/*.rb')).each { |path| require path }
      tables = ActiveRecord::Base.connection.tables
      models = tables.map{|table| Object.const_get(table.classify) rescue nil}.compact

      if format == "excel"
        require 'axlsx'
        Axlsx::Package.new do |pkg|
          wb = pkg.workbook
          sty = wb.styles.add_style :font_name => Setting.manifestation_list_print_excelx.fontname
          wb.add_worksheet(:name => "DB Shemes") do |sheet|
            models.each do |model|
              sheet.add_row []
              sheet.add_row ["#{model.to_s}", "#{model.table_name}", I18n.t("activerecord.models.#{model.to_s.underscore}")], :types => :string, :style => sty
              sheet.add_row []

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
                sheet.add_row cols, :types => :string, :style => sty
              end

              # table index
              sheet.add_row []
              sheet.add_row ["database indexes"]
              sheet.add_row []
              sheet.add_row ["pk", "#{ActiveRecord::Base.connection.primary_key(model.table_name)}"]
              ActiveRecord::Base.connection.indexes(model.table_name).each_with_index do |index, i|
                sheet.add_row ["#{i+1}", "#{index.name}", "#{index.columns.join(',')}"], :types => :string, :style => sty
              end

              # associations
             association_macros.each do |macro|
                sheet.add_row []
                sheet.add_row ["association", "#{association_names[macro]}"], :types => :string, :style => sty
                sheet.add_row []
                begin
                  model.reflect_on_all_associations(macro).each_with_index do |r, i|
                    sheet.add_row ["#{i+1}", "#{r.association_foreign_key}", "#{r.table_name}", "#{r.association_primary_key}"], :types => :string, :style => sty

                  end
                rescue 
                  puts "error(#{$!})"
                  #puts $@
                end
              end
            end
          end
          pkg.serialize('enju_db_schema.xlsx')
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
