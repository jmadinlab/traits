require 'spec_helper'
Capybara.default_selector = :css


describe "New Observation Page" do
	
	subject { page }
	let(:admin) { FactoryGirl.create(:admin) }

	before do
		visit signin_path
		fill_in "Email", with: admin.email
		fill_in "Password", with: admin.password
		click_button "Sign in"
	end

	describe "new observation" do
		before { visit new_observation_path }
		it { should have_content('New Observation')}
		it { should have_content('Measurements')}
		it { should have_selector("select[class=my_trait]") }

		#select('8', :from => "observation_measurements_attributes_0_trait_id" )
		
		find("observation_measurements_attributes_0_trait_id" )

	end

end