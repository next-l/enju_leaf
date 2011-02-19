# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Subject do
  fixtures :subjects

  it "should get term" do
    subjects(:subject_00001).term.should be_true
  end
end
