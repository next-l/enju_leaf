Factory.define :series_statement_merge do |f|
  f.series_statement_merge_list{Factory(:series_statement_merge_list)}
  f.series_statement{Factory(:series_statement)}
end
