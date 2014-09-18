require 'spec_helper'

describe "User pages" do

  subject { page }

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after(:each) do
	  ActionMailer::Base.deliveries.clear
	end

  describe "signin page" do
  	
		let(:user) { FactoryGirl.create(:user) }
		
		before { visit signin_path }

		before do
			fill_in "Email", with: user.email
			fill_in "Password", with: user.password
			click_button "Sign in"
		end

		
		before { visit user_path(user) }

		it { should have_content(user.name) }
		it { should have_title(user.name) }
		
  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_content('Sign Up') }
    it { should have_title('Sign Up') }
  end

  describe "signup" do
		before { visit signup_path }
		let(:submit) { "Submit" }

		describe "with valid information"  do
			before do
				fill_in "Name", with: "Test User"
				fill_in "Email", with: "test@coraltraits.org"
				fill_in "Password", with: "test123"
				fill_in "Confirm Password", with: "test123"

			end

			it "should create a user" do
				expect { click_button submit }.to change(User, :count).by(1)
			end

			it "should send an email" do
				click_button submit
				ActionMailer::Base.deliveries.count.should == 1
			end

			it "renders the receiver email" do
				click_button submit
				ActionMailer::Base.deliveries.first.to.first.should == "test@coraltraits.org"
			end

			it "renders the sender email" do
				click_button submit
				ActionMailer::Base.deliveries.first.from.first.should == "coraltraits@gmail.com"
			end
		end

		describe "with invalid information" do
			it "should not create a user" do
				expect { click_button submit }.not_to change(User, :count)
			end

			it "should not send an email" do
				click_button submit
				ActionMailer::Base.deliveries.count.should == 0
			end
		end
	

  end
end