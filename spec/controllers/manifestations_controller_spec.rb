# encoding: utf-8
require 'spec_helper'

describe ManifestationsController do
  fixtures :all

  describe "GET index", :solr => true do
    shared_examples_for 'index can get a collation' do
      describe "When no record found" do
        let(:exact_title) { "RailsによるアジャイルWebアプリケーション開発" }
        let(:typo_title)  { "RailsによるアジイャルWebアプリケーション開発" }

        before do
          Sunspot.remove_all!

          @manifestation = FactoryGirl.create(
            :manifestation,
            :original_title => exact_title,
            :manifestation_type => FactoryGirl.create(:manifestation_type))
          @item = FactoryGirl.create(
            :item_book,
            :retention_period => FactoryGirl.create(:retention_period),
            :manifestation => @manifestation)

          Sunspot.commit
        end

        it "assings a collation as @collation" do
          get :index, :query => typo_title, :all_manifestations => 'true'
          assigns(:manifestations).should be_empty
          assigns(:collation).should be_present
          assigns(:collation).should == [exact_title]
        end

        it "doesn't assing @collation" do
          get :index, :query => exact_title, :all_manifestations => 'true'
          assigns(:manifestations).should be_present
          assigns(:collation).should be_blank
        end
      end
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all manifestations as @manifestations" do
        get :index
        assigns(:manifestations).should_not be_nil
      end

      include_examples 'index can get a collation'
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all manifestations as @manifestations" do
        get :index
        assigns(:manifestations).should_not be_nil
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all manifestations as @manifestations" do
        get :index
        assigns(:manifestations).should_not be_nil
      end
    end

    describe "When not logged in" do
      it "assigns all manifestations as @manifestations" do
        get :index
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations in sru format without operation" do
        get :index, :format => 'sru'
        assert_response :success
        assigns(:manifestations).should be_nil
        response.should render_template('manifestations/explain')
      end

      it "assigns all manifestations as @manifestations in sru format with operation" do
        get :index, :format => 'sru', :operation => 'searchRetrieve', :query => 'ruby'
        assigns(:manifestations).should_not be_nil
        response.should render_template('manifestations/index')
      end

      it "assigns all manifestations as @manifestations in sru format with operation and title" do
        get :index, :format => 'sru', :query => 'title=ruby', :operation => 'searchRetrieve'
        assigns(:manifestations).should_not be_nil
        response.should render_template('manifestations/index')
      end

      it "assigns all manifestations as @manifestations in openurl" do
        get :index, :api => 'openurl', :title => 'ruby'
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations when pub_date_from and pub_date_to are specified" do
        get :index, :pub_date_from => '2000', :pub_date_to => '2007'
        assigns(:query).should eq "pub_date_sm:[#{Time.zone.parse('2000-01-01').utc.iso8601} TO #{Time.zone.parse('2007-12-31').end_of_year.utc.iso8601}]"
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations when acquired_from and pub_date_to are specified" do
        get :index, :acquired_from => '2000', :acquired_to => '2007'
        assigns(:query).should eq "acquired_at_sm:[#{Time.zone.parse('2000-01-01').utc.iso8601} TO #{Time.zone.parse('2007-12-31').end_of_day.utc.iso8601}]"
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations when number_of_pages_at_least and number_of_pages_at_most are specified" do
        get :index, :number_of_pages_at_least => '100', :number_of_pages_at_least => '200'
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations in mods format" do
        get :index, :format => 'mods'
        assigns(:manifestations).should_not be_nil
        response.should render_template("manifestations/index")
      end

      it "assigns all manifestations as @manifestations in rdf format" do
        get :index, :format => 'rdf'
        assigns(:manifestations).should_not be_nil
        response.should render_template("manifestations/index")
      end

      it "assigns all manifestations as @manifestations in oai format without verb" do
        get :index, :format => 'oai'
        assigns(:manifestations).should_not be_nil
        response.should render_template("manifestations/index")
      end

      it "assigns all manifestations as @manifestations in oai format with ListRecords" do
        get :index, :format => 'oai', :verb => 'ListRecords'
        assigns(:manifestations).should_not be_nil
        response.should render_template("manifestations/list_records")
      end

      it "assigns all manifestations as @manifestations in oai format with ListIdentifiers" do
        get :index, :format => 'oai', :verb => 'ListIdentifiers'
        assigns(:manifestations).should_not be_nil
        response.should render_template("manifestations/list_identifiers")
      end

      it "assigns all manifestations as @manifestations in oai format with GetRecord without identifier" do
        get :index, :format => 'oai', :verb => 'GetRecord'
        assigns(:manifestations).should be_nil
        assigns(:manifestation).should be_nil
        response.should render_template('manifestations/index')
      end

      it "assigns all manifestations as @manifestations in oai format with GetRecord with identifier" do
        get :index, :format => 'oai', :verb => 'GetRecord', :identifier => 'oai:localhost:manifestations-1'
        assigns(:manifestations).should be_nil
        assigns(:manifestation).should_not be_nil
        response.should render_template('manifestations/show')
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        assigns(:manifestation).should eq(Manifestation.find(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        assigns(:manifestation).should eq(Manifestation.find(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        assigns(:manifestation).should eq(Manifestation.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        assigns(:manifestation).should eq(Manifestation.find(1))
      end

      it "guest should show manifestation mods template" do
        get :show, :id => 22, :format => 'mods'
        assigns(:manifestation).should eq Manifestation.find(22)
        response.should render_template("manifestations/show")
      end

      it "should show manifestation rdf template" do
        get :show, :id => 22, :format => 'rdf'
        assigns(:manifestation).should eq Manifestation.find(22)
        response.should render_template("manifestations/show")
      end

      it "should_show_manifestation_with_isbn" do
        get :show, :isbn => "4798002062"
        response.should redirect_to manifestation_url(assigns(:manifestation))
      end

      it "should_show_manifestation_with_isbn" do
        get :show, :isbn => "47980020620"
        response.should be_missing
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested manifestation as @manifestation" do
        get :new
        assigns(:manifestation).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested manifestation as @manifestation" do
        get :new
        assigns(:manifestation).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested manifestation as @manifestation" do
        get :new
        assigns(:manifestation).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested manifestation as @manifestation" do
        get :new
        assigns(:manifestation).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        assigns(:manifestation).should eq(manifestation)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        assigns(:manifestation).should eq(manifestation)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:manifestation)
      @invalid_attrs = {:original_title => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          assigns(:manifestation).should be_valid
        end

        it "redirects to the created manifestation" do
          post :create, :manifestation => @attrs
          response.should redirect_to(manifestation_url(assigns(:manifestation)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :manifestation => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          assigns(:manifestation).should be_valid
        end

        it "redirects to the created manifestation" do
          post :create, :manifestation => @attrs
          response.should redirect_to(manifestation_url(assigns(:manifestation)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :manifestation => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          assigns(:manifestation).should be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          assigns(:manifestation).should be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @manifestation = FactoryGirl.create(:manifestation)
      @attrs = FactoryGirl.attributes_for(:manifestation)
      @invalid_attrs = {:original_title => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          assigns(:manifestation).should eq(@manifestation)
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          assigns(:manifestation).should eq(@manifestation)
          response.should redirect_to(@manifestation)
        end
      end

      describe "with invalid params" do
        it "assigns the manifestation as @manifestation" do
          put :update, :id => @manifestation, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @manifestation, :manifestation => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          assigns(:manifestation).should eq(@manifestation)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @manifestation = FactoryGirl.create(:manifestation)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "redirects to the manifestations list" do
        delete :destroy, :id => @manifestation.id
        response.should redirect_to(manifestations_url)
      end

      it "should not destroy the reserved manifestation" do
        delete :destroy, :id => 2
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation.id
        response.should redirect_to(manifestations_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
