require 'spec_helper'

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

		page.find('#measurements .nested-fields select[id*=trait_id]').set("8")

	end

end