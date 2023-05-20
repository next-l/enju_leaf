csv = (Manifestation.csv_header(role: current_user_role_name) + Item.csv_header(role: current_user_role_name)).to_csv(col_sep: "\t")

@manifestations.map{|manifestation|
  if policy_scope(manifestation.items).empty?
    csv += manifestation.to_hash(role: current_user_role_name).values.to_csv(col_sep: "\t")
  else
    policy_scope(manifestation.items).each do |item|
      csv += (manifestation.to_hash(role: current_user_role_name).values + item.to_hash(role: current_user_role_name).values).to_csv(col_sep: "\t")
    end
  end
}

csv
