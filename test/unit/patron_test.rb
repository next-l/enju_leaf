require 'test_helper'

class PatronTest < ActiveSupport::TestCase
  fixtures :patrons, :realizes, :produces, :manifestations, :patron_types, :languages, :countries

  # Replace this with your real tests.
  def test_patron_should_be_creator
    assert patrons(:patron_00001).creator?(manifestations(:manifestation_00001))
  end

  def test_patron_should_not_be_creator
    assert !patrons(:patron_00010).creator?(manifestations(:manifestation_00001))
  end

  def test_patron_should_be_publisher
    assert patrons(:patron_00001).publisher?(manifestations(:manifestation_00001))
  end

  def test_patron_should_not_be_publisher
    assert !patrons(:patron_00010).publisher?(manifestations(:manifestation_00001))
  end

  def test_patron_full_name
    assert_equal 'Kosuke Tanabe', patrons(:patron_00003).full_name
  end

end
