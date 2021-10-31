Event.csv_header(
  role: current_user_role_name
).to_csv(col_sep: "\t") + @events.map{|event|
  event.to_hash(
    role: current_user_role_name
  ).values.to_csv(col_sep: "\t")
}.join
