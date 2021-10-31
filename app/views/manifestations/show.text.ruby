Manifestation.csv_header(
  role: current_user_role_name
).to_csv(col_sep: "\t") + @manifestation.to_hash(
  role: current_user_role_name
).values.to_csv(col_sep: "\t")
