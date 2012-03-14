# -*- encoding: utf-8 -*-
require 'spec_helper'

describe ZipCodeList do
  fixtures :zip_code_lists

  context "generate barcode" do

    it "shoud raise exception (1)" do
      proc {
        ZipCodeList.generate_japanpost_customer_code(nil , nil) 
      }.should raise_error(ArgumentError, "zip_code or address is empty.")
    end

    it "shoud raise exception (2)" do
      proc {
        ZipCodeList.generate_japanpost_customer_code("3340021" , nil) 
      }.should raise_error(ArgumentError, "zip_code or address is empty.")
    end

    it "shoud raise exception (3)" do
      proc {
        ZipCodeList.generate_japanpost_customer_code("113-0021" , "東京都文京区本駒込6-1-21") 
      }.should raise_error(ArgumentError, "zip_code is invalid. (no record)")
    end

    it "shoud return customer code (1)" do
      h = {:z=>"263-0023", :a=>"千葉市稲毛区緑町3丁目30-8　郵便ビル403号", :ans=>"26300233-30-8-403"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end

    it "shoud return customer code (2)" do
      h = {:z=>"014-0113", :a=>"秋田県大仙市堀見内　南田茂木　添60-1", :ans=>"014011360-1"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end

    it "shoud return customer code (3)" do
      h = {:z=>"110-0016", :a=>"東京都台東区台東5-6-3　ABCビル10F", :ans=>"11000165-6-3-10"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end

    it "shoud return customer code (4)" do
      h = {:z=>"060-0906", :a=>"北海道札幌市東区北六条東4丁目　郵便センター6号館", :ans=>"06009064-6"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end

    it "shoud return customer code (5)" do
      h = {:z=>"065-0006", :a=>"北海道札幌市東区北六条東8丁目　郵便センター10号館", :ans=>"06500068-10"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end

    it "shoud return customer code (6)" do
      h = {:z=>"407-0033", :a=>"山梨県韮崎市龍岡町下條南割　韮崎400", :ans=>"4070033400"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end

    it "shoud return customer code (7)" do
      h = {:z=>"2730102", :a=>"千葉県鎌ケ谷市右京塚　東3丁目-20-5　郵便・A&bコーポB604号", :ans=>"27301023-20-5B604"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end

    it "shoud return customer code (8)" do
      h =  {:z=>"1980036", :a=>"東京都青梅市河辺町十一丁目六番地一号　郵便タワー601", :ans=>"198003611-6-1-601"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end

    it "shoud return customer code (9)" do
      h = {:z=>"0270203", :a=>"岩手県宮古市大字津軽石第二十一地割大淵川480", :ans=>"027020321-480"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end

    it "shoud return customer code (10)" do
      h = {:z=>"5900016", :a=>"大阪府堺市堺区中田出井町四丁六番十九号", :ans=>"59000164-6-19"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end

    it "shoud return customer code (11)" do
      h = {:z=>"0800831", :a=>"北海道帯広市稲田町南七線　西28", :ans=>"08008317-28"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end
 
    it "shoud return customer code (12)" do
      h = {:z=>"3170055", :a=>"茨城県日立市宮田町6丁目7-14　ABCビル2F", :ans=>"31700556-7-14-2"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end

    it "shoud return customer code (13)" do
      h = {:z=>"6500046", :a=>"神戸市中央区港島中町9丁目7-6　郵便シティA棟1F1号", :ans=>"65000469-7-6A1-1"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end

    it "shoud return customer code (14)" do
      h = {:z=>"6230011", :a=>"京都府綾部市青野町綾部6-7　LプラザB106", :ans=>"62300116-7LB106"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end

    it "shoud return customer code (15)" do
      h = {:z=>"2280024", :a=>"神奈川県座間市入谷6丁目3454-5　郵便ハイツ6-1108", :ans=>"22800246-3454-5-6-112"}
      proc {
        ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      }.should raise_error(ArgumentError, "zip_code is invalid. (no record)")
    end

    it "shoud return customer code (16)" do
      h = {:z=>"0640804", :a=>"札幌市中央区南四条西29丁目1524-23　第2郵便ハウス501", :ans=>"064080429-1524-23-2-3"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end
 
    it "shoud return customer code (17)" do
      h = {:z=>"9100067", :a=>"福井県福井市新田塚3丁目80-25　J1ビル2-B", :ans=>"91000673-80-25J1-2B"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:ans]
    end
 



  end
end
