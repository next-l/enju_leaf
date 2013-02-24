# -*- encoding: utf-8 -*- 
require 'spec_helper'

describe Numbering do
  fixtures :numberings

  describe 'success' do
    it "fixturesから正しく読めること" do
      @numberings = Numbering.find(:all)
      @numberings.size.should == 8
    end

		it "保存出来ること" do
			n = Numbering.new({:name=>'test', :display_name=>'test_disp'})
			n.save!
			n.name.should == 'test'
			n.display_name.should == 'test_disp'
		end

  end

	describe 'padding' do
		it "padding" do
			@numberings = Numbering.find_by_name('book')
			@numberings.padding?.should be_true
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
  end

  describe '競合チェック' do
    it '同時実行で取得できること' do
      t1 = Thread.new do
        20.times do
          numbering = Numbering.do_numbering('book')
          numbering.should_not be_nil
          #puts "test1 =#{numbering}"
          sleep 0.3
        end
      end
      t2 = Thread.new do
        20.times do
          numbering = Numbering.do_numbering('book')
          numbering.should_not be_nil
          #puts "test2 =#{numbering}"
          sleep 0.2
        end
      end

      t1.join
      t2.join

      numbering = Numbering.do_numbering('book')
      numbering.should == "100000041"
    end
  end

end
