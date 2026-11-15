def update_use_restriction
  lines = YAML.safe_load(open("db/fixtures/enju_circulation/use_restrictions.yml").read).map do |line|
    line[1].select! { |k, v| %w(name display_name).include?(k) }
  end
  use_restrictions_by_name = UseRestriction.where(name: lines.map { |l| l["name"] }).index_by(&:name)
  lines.each do |l|
    use_restrictions_by_name[l["name"]].try(:update_attributes!, l)
  end
end
