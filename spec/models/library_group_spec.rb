# -*- encoding: utf-8 -*-
require 'spec_helper'

describe LibraryGroup do
  fixtures :library_groups

  it "should get library_group_config" do
    LibraryGroup.site_config.should be_true
  end
end
