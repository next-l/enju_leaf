Factory.define :patron_merge do |f|
  f.patron_merge_list{Factory(:patron_merge_list)}
  f.patron{Factory(:patron)}
end
