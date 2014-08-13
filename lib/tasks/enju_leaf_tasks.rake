require 'active_record/fixtures'
namespace :enju_leaf do
  desc "create initial records for enju_leaf"
  task :setup => :environment do
    Dir.glob(Rails.root.to_s + '/db/fixtures/enju_leaf/*.yml').each do |file|
      ActiveRecord::Fixtures.create_fixtures('db/fixtures/enju_leaf', File.basename(file, '.*'))
    end

    Rake::Task['enju_biblio:setup'].invoke
    Rake::Task['enju_library:setup'].invoke

    puts 'initial fixture files loaded.'
  end

  desc "import users from a TSV file"
  task :user_import => :environment do
    UserImportFile.import
  end

  desc "upgrade enju_leaf"
  task :upgrade => :environment do
    version = EnjuLeaf::VERSION.split('.')
    if version[0..2] == ["1", "1" ,"0"]
      if version[3] == 'rc13'
        Exemplify.transaction do
          Exemplify.find_each do |exemplify|
            if exemplify.item
              exemplify.item.update_column(:manifestation_id, exemplify.manifestation_id)
            end
          end

          User.find_each do |user|
            profile = Profile.new
            profile.user = user
            profile.user_group = user.user_group
            profile.library = user.library
            profile.required_role = user.required_role
            profile.user_number = user.user_number
            profile.keyword_list = user.keyword_list
            profile.locale = user.locale
            profile.note = user.note
            profile.save
          end

          Reserve.find_each do |reserve|
            ReserveTransition.create(reserve_id: 1, sort_key: 0, to_state: reserve.state)
          end

          YAML.load(open('db/fixtures/enju_circulation/circulation_statuses.yml').read).each do |line|
            l = line[1].select!{|k, v| %w(name display_name).include?(k)}
            CirculationStatus.where(name: l["name"]).first.try(:update_attributes!, l)
          end

          YAML.load(open('db/fixtures/enju_circulation/use_restrictions.yml').read).each do |line|
            l = line[1].select!{|k, v| %w(name display_name).include?(k)}
            UseRestriction.where(name: l["name"]).first.try(:update_attributes!, l)
          end

          YAML.load(open('db/fixtures/enju_message/message_templates.yml').read).each do |line|
            l = line[1].select!{|k, v| %w(status locale title body).include?(k)}
            template = MessageTemplate.where(
              status: l["status"], locale: l["locale"]
            ).first
            if template
              template.update_attributes!(l)
            else
              MessageTemplate.create!(l)
            end
          end
        end
      end
    end

    puts 'The upgrade completed successfully.'
  end
end
