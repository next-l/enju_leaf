# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :resource_import_textfile do
    resource_import_text_file_name 'foo.txt'
  end
end
