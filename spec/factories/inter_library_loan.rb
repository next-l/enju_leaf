Factory.define :inter_library_loan do |f|
  f.item{Factory(:item)}
  f.borrowing_library{Factory(:library)}
end
