csv = (Manifestation.csv_header(role: current_user_role_name) + Item.csv_header(role: current_user_role_name)).to_csv(col_sep: "\t")

if Pundit.policy_scope!(current_user, @manifestation.items).empty?
  csv += @manifestation.to_hash(role: current_user_role_name).values.to_csv(col_sep: "\t")
else
  Pundit.policy_scope!(current_user, @manifestation.items).each do |item|
    csv += (item.manifestation.to_hash(role: current_user_role_name).values + item.to_hash(role: current_user_role_name).values).to_csv(col_sep: "\t")
  end
end

csv
