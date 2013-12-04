require 'spec_helper'

describe RelationshipFamily do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  describe 'validates' do
    describe 'presence' do
      context 'when display_name is filled' do
        subject { RelationshipFamily.new(:display_name => 'test') }
        it { should be_valid }
      end
      context 'when display_name is nil' do
        subject { RelationshipFamily.new(:display_name => nil) }
        it { should_not be_valid }
      end
    end
  end
end
