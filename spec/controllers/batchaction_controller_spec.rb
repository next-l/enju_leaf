require 'spec_helper'

describe BatchactionController do

  describe "GET 'recept'" do
    it "should be successful" do
      get 'recept'
      response.should be_success
    end
  end

end
