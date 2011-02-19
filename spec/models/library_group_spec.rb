# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Donate do
  fixtures :library_groups

  it "should getlibrary_group_config" do
    LibraryGroup.site_config.should be_true
  end
end
