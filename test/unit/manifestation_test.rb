# -*- encoding: utf-8 -*-
require 'test_helper'

class ManifestationTest < ActiveSupport::TestCase
  fixtures :manifestations, :items,
    :reserves, :users, :roles, :languages, :realizes, :creates, :produces,
    :frequencies, :form_of_works, :content_types, :carrier_types, :countries, :patron_types,
    :answer_has_items

  def test_reserved
    assert manifestations(:manifestation_00007).is_reserved_by(users(:admin))
  end

  def test_not_reserved
    assert_nil manifestations(:manifestation_00007).is_reserved_by(users(:user1))
  end

  def test_manifestation_should_show_languages
    assert manifestations(:manifestation_00001).language
  end

  #def test_manifestation_should_show_oai_dc
  #  assert manifestations(:manifestation_00001).to_oai_dc
  #end

  def test_manifestation_should_get_number_of_pages
    assert_equal 100, manifestations(:manifestation_00001).number_of_pages
  end

  def test_manifestation_should_import_isbn
    assert Manifestation.import_isbn('4797327030')
  end

  def test_youtube_id
    assert_equal manifestations(:manifestation_00022).youtube_id, 'BSHBzd9ftDE'
  end

  def test_nicovideo_id
    assert_equal manifestations(:manifestation_00023).nicovideo_id, 'sm3015373'
  end

  def test_manifestation_should_respond_to_pickup
    assert Manifestation.pickup
  end

  def test_manifestation_should_respond_to_title
    assert manifestations(:manifestation_00001).title
  end

  def test_manifestation_should_have_screen_shot
    assert manifestations(:manifestation_00003).screen_shot
  end

  def test_manifestation_should_not_have_parent_of_series
    assert manifestations(:manifestation_00001).parent_of_series
  end

  def test_manifestation_should_response_to_extract_text
    assert_nil manifestations(:manifestation_00001).extract_text
  end

  def test_manifestation_should_not_be_reserved_if_it_has_no_item
    assert_equal false, manifestations(:manifestation_00008).reservable?
  end

end
