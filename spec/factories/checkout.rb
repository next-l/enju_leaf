FactoryGirl.define do
  factory :adult_checkout, :class => Checkout do |f|
    f.basket_id{FactoryGirl.create(:adult_basket).id}
    f.item_id{Item.joins(:manifestation).where("item_identifier like 'book_%' AND manifestations.ndc IS NULL").first.id}
    f.librarian_id{User.where(:library_id => Library.where(:name => "liba").first.id).first.id}
    f.user_id{User.find(:first, :conditions => ['username like ?', 'adult%']).id}
    f.due_date Date.tomorrow
  end
  factory :student_checkout, :class => Checkout do |f|
    f.basket_id{FactoryGirl.create(:student_basket).id}
    f.item_id{Item.joins(:manifestation).where("item_identifier like 'book_%' AND manifestations.ndc IS NULL").first.id}
    f.librarian_id{User.where(:library_id => Library.where(:name => "libb").first.id).first.id}
    f.user_id{User.find(:first, :conditions => ['username like ?', 'student%']).id}
    f.due_date Date.tomorrow
  end
  factory :juniors_checkout, :class => Checkout do |f|
    f.basket_id{FactoryGirl.create(:juniors_basket).id}
    f.item_id{Item.joins(:manifestation).where("item_identifier like 'serial_%' AND manifestations.ndc IS NULL").first.id}
    f.librarian_id{User.where(:library_id => Library.where(:name => "liba").first.id).first.id}
    f.user_id{User.find(:first, :conditions => ['username like ?', 'juniors%']).id}
    f.due_date Date.tomorrow
  end
  factory :elements_checkout, :class => Checkout do |f|
    f.basket_id{FactoryGirl.create(:elements_basket).id}
    f.item_id{Item.joins(:manifestation).where("item_identifier like 'serial_%' AND manifestations.ndc IS NULL").first.id}
    f.librarian_id{User.where(:library_id => Library.where(:name => "libb").first.id).first.id}
    f.user_id{User.find(:first, :conditions => ['username like ?', 'elements%']).id}
    f.due_date Date.tomorrow
  end
  factory :children_checkout, :class => Checkout do |f|
    f.basket_id{FactoryGirl.create(:children_basket).id}
    f.item_id{Item.joins(:manifestation).where("item_identifier like 'cd_%' AND manifestations.ndc IS NULL").first.id}
    f.librarian_id{User.where(:library_id => Library.where(:name => "liba").first.id).first.id}
    f.user_id{User.find(:first, :conditions => ['username like ?', 'children%']).id}
    f.due_date Date.tomorrow
  end
end
