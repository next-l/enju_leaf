# -*- coding: utf-8 -*-
require 'spec_helper'
 
describe FactoryGirl do
  fixtures :all

  black_list = {
    :invalid_patron => 'generates an invalid record',
    :invalid_library => 'generates an invalid record',
#    :libraryA => 'fails because Library.create builds an invalid patron record internally [BUG?]',
#    :libraryB => 'fails because Library.create builds an invalid patron record internally [BUG?]',
    :order => 'calls undefined method MessageRequest.send_notice_to_libraries [BUG?]',
  }

  klasses = FactoryGirl.factories.map &:name
 
  klasses.each do |name|
    describe name do
      if msg = black_list[name]
        pending msg
      else
        subject { FactoryGirl.build( name ).tap { |x| x.valid? } }
        its(:"errors.to_a") { should == [] }
      end
    end
  end
end
