CSV.generate(col_sep: "\t", row_sep: "\r\n") do |csv|
  @resource_import_results.each_with_index do |result|
    csv << result.body.split("\t")
  end
end
