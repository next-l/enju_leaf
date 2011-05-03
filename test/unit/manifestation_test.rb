# -*- encoding: utf-8 -*-
require 'test_helper'

class ManifestationTest < ActiveSupport::TestCase
  fixtures :manifestations, :items,
    :reserves, :users, :roles, :languages, :realizes, :creates, :produces,
    :frequencies, :form_of_works, :content_types, :carrier_types, :countries, :patron_types,
    :answer_has_items

  def test_manifestation_should_import_isbn
    assert Manifestation.import_isbn('4797327030')
  end

  def test_manifestation_should_respond_to_pickup
    assert Manifestation.pickup
  end

  def test_manifestation_should_respond_to_title
    assert manifestations(:manifestation_00001).title
  end
end
