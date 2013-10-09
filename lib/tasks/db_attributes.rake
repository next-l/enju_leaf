namespace :enju do
  namespace :db do
    desc 'print attributes'
    task :desc => :environment do
      CONST_COLUMN = {"created_at"=>I18n.t('page.created_at'),
                      "updated_at"=>I18n.t('page.updated_at'),
                      "id"=>'ID',
                     }
      Dir.glob(Rails.root.join('app/models/**/*.rb')).each { |path| require path }
      tables = ActiveRecord::Base.connection.tables
      models = tables.map{|table| Object.const_get(table.classify) rescue nil}.compact

      models.each { |model|
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
        # associations
        association_names = {:has_one=>"1:1", :has_many=>"1:N", :belongs_to=>"N:1"}
        association_vectors = {:has_one=>"<=>", :has_many=>"=>", :belongs_to=>"<="}
        association_macros = [:has_one, :has_many, :belongs_to]
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
            puts "error(#{$!})"
            #puts $@
          end
        end
      }
    end
  end
end
