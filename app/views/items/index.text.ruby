csv = %w[title isbn item_identifier call_number created_at].to_csv(col_sep: "\t")

@items.map{|item|
  [
    item.manifestation.original_title,
    item.manifestation.identifier_contents(:isbn).join("; "),
    item.item_identifier,
    item.call_number,
    item.created_at
  ]
}

csv
