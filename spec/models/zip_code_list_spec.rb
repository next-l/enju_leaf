# -*- encoding: utf-8 -*-
require 'spec_helper'

describe ZipCodeList do
  context "generate barcode" do
    it "test1" do
      h = {:z=>"263-0023", :a=>"千葉市稲毛区緑町3丁目30-8　郵便ビル403号", :ans=>"26300233-30-8-403"}
      ans = ZipCodeList.generate_japanpost_customer_code(h[:z], h[:a]) 
      ans.should eq h[:a]
    end
  end
end
