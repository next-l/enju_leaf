FactoryGirl.define do
  factory :import_request do |f|
    f.sequence :isbn do |n|
      isbn = "%012d0"%n
      checksum = Lisbn.new(isbn).instance_eval { isbn_13_checksum }
      "%012d%d"%[n, checksum]
    end
  end
end
