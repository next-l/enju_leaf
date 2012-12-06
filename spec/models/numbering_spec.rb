# -*- encoding: utf-8 -*- 
require 'spec_helper'

describe Numbering do
  fixtures :numberings

  describe 'success' do
    it "fixturesから正しく読めること" do
      @numberings = Numbering.find(:all)
      @numberings.size.should == 8
    end

  end

  describe 'generate_checkdigit_modulas10_weight3' do
    it 'success' do
      @n = Numbering.new
      d = @n.generate_checkdigit_modulas10_weight3(192005502800)
      #puts "d=#{d}"
      d.should == 4
    end
  end

  describe 'self.do_numbering' do
    it '存在しない区分はエラーになること' do
      lambda { Numbering.do_numbering('') }.should raise_error(EnjuTrunkNumberingError)
    end

    it 'haikiが採番出来ること' do
      numbering = Numbering.do_numbering('haiki')
      numbering.should == "F0000000001"
    end

    it 'checkdigit-sampleが採番出来ること' do
      numbering = Numbering.do_numbering('checkdigit-sample')
      numbering.should == "01920055028004"
    end

    it '連続して採番出来ること' do
      numbering = Numbering.do_numbering('book')
      numbering.should == "100000001"
      numbering = Numbering.do_numbering('book')
      numbering.should == "100000002"
    end

    it '競合チェック' do

    end
  end
end
