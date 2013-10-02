namespace :enju do
  namespace :db do
    desc 'print attributes'
    task :desc => :environment do
      Dir.glob(Rails.root.join('app/models/**/*.rb')).each { |path| require path }
      tables = ActiveRecord::Base.connection.tables
      models = tables.map{|table| Object.const_get(table.classify) rescue nil}.compact

      models.each { |model|
        puts ""
        print "Model=#{model.to_s} "
        print I18n.t("activerecord.models.#{model.to_s.underscore}")
        puts ""
        puts ""
        model.columns.each { |column|
          print sprintf("|%s|%s|%s|", column.name, column.type, column.sql_type)
          print I18n.t("activerecord.attributes.#{model.to_s.underscore}.#{column.name}")
          puts ""
        }
      }
    end
  end
end
