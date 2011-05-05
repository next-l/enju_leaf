Factory.define :bookmark do |f|
  f.sequence(:title){|n| "bookmark_#{n}"}
  f.sequence(:url){|n| "http://example.jp/#{n}"}
  f.user{Factory(:user)}
end
