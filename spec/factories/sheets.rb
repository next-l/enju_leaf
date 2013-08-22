# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sheet do
    name "MyString"
    note "MyText"
    height 1.5
    width 1.5
    margin_h 1.5
    margin_w 1.5
    space_h 1.5
    space_w 1.5
    cell_x 1
    cell_y 1
    cell_h 1.5
    cell_w 1.5
  end
end
