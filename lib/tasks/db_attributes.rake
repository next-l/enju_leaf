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
      }
    end
  end
end
