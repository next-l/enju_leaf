require 'spec_helper'

describe SeriesStatementRelationshipType do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  describe 'validates' do
    describe 'uniquness' do
      context 'when display_name is unique' do
        subject { FactoryGirl.build(:series_statement_relationship_type, :display_name => 'test') }
        it      { should be_valid }
      end  
      context 'when display_name is not unique' do
        subject { FactoryGirl.build(:series_statement_relationship_type) }
        it      { should_not be_valid }
      end  
    end
    describe 'presence' do
      context 'when display_name is filled' do
        subject { FactoryGirl.build(:series_statement_relationship_type, :display_name => 'test') }
        it      { should be_valid }
      end  
      context 'when display_name is not filled' do
        subject { FactoryGirl.build(:series_statement_relationship_type, :display_name => nil) }
        it      { should_not be_valid }
      end  
    end
    describe 'numericality' do
      shared_examples_for 'typeid is numeric' do
        subject { FactoryGirl.build(:series_statement_relationship_type, :display_name => 'test', :typeid => typeid) }
        it { should be_valid }
      end
      shared_examples_for 'typeid is not numeric' do
        subject { FactoryGirl.build(:series_statement_relationship_type, :display_name => 'test', :typeid => typeid) }
        it { should_not be_valid }
      end  
      it_behaves_like 'typeid is numeric'     do let(:typeid) { 0 }    end
      it_behaves_like 'typeid is numeric'     do let(:typeid) { 1 }    end
      it_behaves_like 'typeid is numeric'     do let(:typeid) { 10 }   end
      it_behaves_like 'typeid is not numeric' do let(:typeid) { 'a' }  end
      it_behaves_like 'typeid is not numeric' do let(:typeid) { 'a0' } end
      it_behaves_like 'typeid is not numeric' do let(:typeid) { '0a' } end
    end
  end
end
