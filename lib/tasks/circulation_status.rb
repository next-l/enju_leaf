def update_circulation_status
  YAML.safe_load(open('db/fixtures/enju_circulation/circulation_statuses.yml').read).each do |line|
    l = line[1].select!{|k, v| %w(name display_name).include?(k)}
    CirculationStatus.where(name: l["name"]).first.try(:update_attributes!, l)
  end
end
