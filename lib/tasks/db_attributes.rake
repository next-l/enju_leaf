namespace :enju do
  namespace :db do
    desc 'print attributes'
    task :desc => :environment do
      [Manifestation, Item, SeriesStatement].each { |model|
        puts ""
        print "Model=#{model.to_s} "
        print I18n.t("activerecord.models.#{model.to_s.underscore}")
        puts ""
        puts ""
        model.columns.each { |column|
          print sprintf("|%20s|%20s|%30s|", column.name, column.type, column.sql_type)
          print I18n.t("activerecord.attributes.#{model.to_s.underscore}.#{column.name}")
          puts ""
        }
      }
    end
  end
end
