require 'resync'
namespace :enju_leaf do
  namespace :resourcesync do
    desc 'capabilitylist'
    task :capabilitylist => :environment do |task|
      xml = Resourcesync.new.generate_capabilitylist
      formatter = REXML::Formatters::Default.new

      File.open(Rails.root.join("public/capabilitylist.xml"), 'w') do |f|
        formatter.write(xml, f)
      end
    end

    desc 'resourcelist'
    task :resourcelist => :environment do |task|
      manifestations = Manifestation.where(required_role_id: 1)
      resourcelist_index_xml = Resourcesync.new.generate_resourcelist_index(manifestations)
      resourcelist_xml = Resourcesync.new.generate_resourcelist(manifestations)
      formatter = REXML::Formatters::Default.new

      File.open(Rails.root.join("public/resourcelist.xml"), 'w') do |f|
        formatter.write(resourcelist_index_xml, f)
      end

      resourcelist_xml.each_with_index do |resourcelist_xml, i|
        File.open(Rails.root.join("public/resourcesync/resourcelist_#{i}.xml"), 'w') do |f|
          formatter.write(resourcelist_xml, f)
        end
      end
    end

    desc 'changelist'
    task :changelist, ['date_from'] => :environment do |task, args|
      date_from = Date.parse(args['date_from'])
      manifestations = Manifestation.where(required_role_id: 1).where('manifestations.updated_at >= ?', date_from)
      changelist_index_xml = Resourcesync.new.generate_changelist_index(manifestations)
      changelist_xml = Resourcesync.new.generate_changelist(manifestations)
      formatter = REXML::Formatters::Default.new

      File.open(Rails.root.join("public/changelist.xml"), 'w') do |f|
        formatter.write(changelist_index_xml, f)
      end

      changelist_xml.each_with_index do |changelist_xml, i|
        File.open(Rails.root.join("public/resourcesync/changelist_#{i}.xml"), 'w') do |f|
          formatter.write(changelist_xml, f)
        end
      end
    end
  end
end
