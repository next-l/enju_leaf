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
    it '空からnilを与えた場合は、nilを返すこと' do
      r = Wareki.hiduke2yyyymmdd(nil)
      r.should == [nil, nil]

      r = Wareki.hiduke2yyyymmdd("")
      r.should == [nil, nil]
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
      r = Wareki.hiduke2yyyymmdd("明治12年7月 － 明治14年11月")
      r.should == ["18790701", "18811130"]

      r = Wareki.hiduke2yyyymmdd("[昭和18?年 － 昭和20?年]")
      r.should == ["19430101", "19451231"]

      r = Wareki.hiduke2yyyymmdd("昭和１２年１１月")
      r.should == ["19371101", "19371130"]

      r = Wareki.hiduke2yyyymmdd("昭和１２年１０月１０日")
      r.should == ["19371010", "19371010"]

      r = Wareki.hiduke2yyyymmdd("昭和１８年６月") 
      r.should == ["19430601", "19430630"]

      r = Wareki.hiduke2yyyymmdd("安政4年")
      r.should == ["18580101", "18581231"]

      r = Wareki.hiduke2yyyymmdd("寛政1年")
      r.should == ["17890101", "17891231"]

      r = Wareki.hiduke2yyyymmdd("文政10年")
      r.should == ["18270101", "18271231"]

      r = Wareki.hiduke2yyyymmdd("明治")
      r.should == ["18681023", "19120730"]

      r = Wareki.hiduke2yyyymmdd("大正")
      r.should == ["19120730", "19261225"]

      r = Wareki.hiduke2yyyymmdd("昭和")
      r.should == ["19261225", "19890107"]

      r = Wareki.hiduke2yyyymmdd("平成")
      r.should == ["19890108", "20991231"]
      
      r = Wareki.hiduke2yyyymmdd("明治27年ー昭和12年")
      r.should == ["18940101", "19371231"]

      r = Wareki.hiduke2yyyymmdd("明治9年 10月")
      r.should == ["18761001", "18761031"]

      r = Wareki.hiduke2yyyymmdd("大正15年2?月凡例")
      r.should == ["19260201", "19260228"]

      r = Wareki.hiduke2yyyymmdd("大正元年?")
      r.should == ["19120101", "19121231"]

      r = Wareki.hiduke2yyyymmdd("1644年序")
      r.should == ["16440101", "16441231"]

      r = Wareki.hiduke2yyyymmdd("1826年写")
      r.should == ["18260101", "18261231"]

      r = Wareki.hiduke2yyyymmdd("2009/4～2010/3")
      r.should == ["20090401", "20100331"]

      # 西暦
      r = Wareki.hiduke2yyyymmdd("1974")
      r.should == ["19740101","19741231"]
      r = Wareki.hiduke2yyyymmdd("1974/3")
      r.should == ["19740301","19740331"]
      r = Wareki.hiduke2yyyymmdd("1974/3/9")
      r.should == ["19740309","19740309"]
      r = Wareki.hiduke2yyyymmdd("1974/3/9 - 1979/8/4")
      r.should == ["19740309", "19790804"]

      r = Wareki.hiduke2yyyymmdd("[1914年 － 1915年]")
      r.should == ["19140101", "19151231"]
      r = Wareki.hiduke2yyyymmdd("[1914年3月 － 1915年4月12日]")
      r.should == ["19140301", "19150412"]

      r = Wareki.hiduke2yyyymmdd("1885.05.01")
      r.should == ["18850501", "18850501"]

      # 省略形
      r = Wareki.hiduke2yyyymmdd("H") 
      r.should == ["19890108", "20991231"]
      r = Wareki.hiduke2yyyymmdd("S") 
      r.should == ["19261225", "19890107"]
      r = Wareki.hiduke2yyyymmdd("T") 
      r.should == ["19120730", "19261225"]
      r = Wareki.hiduke2yyyymmdd("M") 
      r.should == ["18681023", "19120730"]

      r = Wareki.hiduke2yyyymmdd("S49.3.9")
      r.should == ["19740309", "19740309"]
 
      r = Wareki.hiduke2yyyymmdd("M27年ーS12年")
      r.should == ["18940101", "19371231"]

      # mix
      r = Wareki.hiduke2yyyymmdd("1974/3/9 - 昭和54年8月4日")
      r.should == ["19740309", "19790804"]

      # 和暦 invalid format
      r = Wareki.hiduke2yyyymmdd("昭和年")
      r.should == [nil, nil]

      r = Wareki.hiduke2yyyymmdd("平成aa")
      r.should == [nil, nil]

      #TODO
      #r = Wareki.hiduke2yyyymmdd("明治27年514月")
      #r.should == [nil, nil]
    end
  end
end
