require 'spec_helper'

describe "UserRequestLog" do
  fixtures :library_groups, :patron_types, :languages, :countries, :user_groups, :roles

  describe "GET /" do
    let(:admin_user) { FactoryGirl.create(:admin) }

    it "add one UserRequestLog record" do
      lambda {
        get '/'
      }.should change(UserRequestLog, :count).by(1)

      log = UserRequestLog.last
      log.user_id.should be_nil
      log.controller.should == controller.class.name
      log.action.should == controller.action_name
      log.data[:path].should == '/'
      log.data[:status].should == response.status

      lambda {
        post '/accounts/sign_in',
          :user => {'username' => admin_user.username, 'password' => 'adminpassword'},
          :commit => 'commit'
      }.should change(UserRequestLog, :count).by(1)

      log = UserRequestLog.last
      log.user_id.should == admin_user.id
      log.data[:params]['user']['username'].should == admin_user.username
      log.data[:params]['user']['password'].should == '[FILTERED]'

      lambda {
        get '/'
      }.should change(UserRequestLog, :count).by(1)

      log = UserRequestLog.last
      log.user_id.should == admin_user.id
    end

    it "add a line to log file when record creation failed" do
      save_logger = [ActiveRecord::Base.logger, ActionController::Base.logger]
      begin
        admin_user.stub(:id) { raise }
        PageController.any_instance.stub(:current_user).and_return(admin_user)

        strio = StringIO.new
        ActiveRecord::Base.logger = ActionController::Base.logger = Logger.new(strio)

        get '/'

        strio.string.should match(/user request log failed:/)

      ensure
        ActiveRecord::Base.logger, ActionController::Base.logger = save_logger
      end
    end
  end
end
