# encoding: utf-8
require 'spec_helper'

describe Wareki do
  describe 'wareki2yyyyは' do
    it '和暦を西暦年に変換すること' do
      r = Wareki.wareki2yyyy("明治", 9)
      r.should == 1876
      r = Wareki.wareki2yyyy("明治", "9")
      r.should == 1876
      r = Wareki.wareki2yyyy("大正", "2")
      r.should == 1913
      r = Wareki.wareki2yyyy("昭和", "49")
      r.should == 1974
      r = Wareki.wareki2yyyy("平成", "25")
      r.should == 2013
    end
  end

  describe 'メソッドhiduke2yyyymmddは' do
    it '日付の範囲を返すこと' do
      # 和暦
      r = Wareki.hiduke2yyyymmdd("昭和49年")
      r.should == ["19740101","19741231"]
      r = Wareki.hiduke2yyyymmdd("昭和49年3月")
      r.should == ["19740301","19740331"]
      r = Wareki.hiduke2yyyymmdd("昭和49年3月9日")
      r.should == ["19740309", "19740309"]
      r = Wareki.hiduke2yyyymmdd("昭和49年-昭和54年")
      r.should == ["19740101", "19791231"]
      r = Wareki.hiduke2yyyymmdd("昭和49年3月9日 - 昭和54年8月4日")
      r.should == ["19740309", "19790804"]

      # 西暦
      r = Wareki.hiduke2yyyymmdd("1974")
      r.should == ["19740101","19741231"]
      r = Wareki.hiduke2yyyymmdd("1974/3")
      r.should == ["19740301","19740331"]
      r = Wareki.hiduke2yyyymmdd("1974/3/9")
      r.should == ["19740309","19740309"]
      r = Wareki.hiduke2yyyymmdd("1974/3/9 - 1979/8/4")
      r.should == ["19740309", "19790804"]

      # mix
      r = Wareki.hiduke2yyyymmdd("1974/3/9 - 昭和54年8月4日")
      r.should == ["19740309", "19790804"]

      # 和暦 invalid format
      r = Wareki.hiduke2yyyymmdd("昭和年")
      r.should == [nil, nil]
 
    end
  end
end
