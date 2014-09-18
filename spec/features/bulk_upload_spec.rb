require 'spec_helper'

describe "Bulk Upload" do
	
	subject { page }
	let(:admin) { FactoryGirl.create(:admin) }
	
	specify { expect(admin.admin? ).to equal(true) }

	before do
		visit signin_path
		fill_in "Email", with: admin.email
		fill_in "Password", with: admin.password
		click_button "Sign in"
	end
	
	describe "import observations" do
		before { visit '/imports/observations'}
		it { should have_content('Upload Observation')}

		it "can import observations" do
			#@file = fixture_file_upload('files/test_file.csv', 'text/csv')
			attach_file "import_file", 'spec/fixtures/files/observation_test_file.csv'
			click_button "Upload"
			expect(page).to have_selector('div.alert.alert-success')

		end

		it "should not import observations with duplicates" do
			attach_file "import_file", 'spec/fixtures/files/observation_test_file.csv'
			click_button "Upload"

			attach_file "import_file", 'spec/fixtures/files/observation_test_file_2.csv'
			click_button "Upload"
			expect(page).to have_selector('div#error_explanation')

		end
	end

	describe "import locations" do
		before { visit '/imports/locations'}
		it { should have_content('Upload Location')}

		it "can import locations" do
			#@file = fixture_file_upload('files/test_file.csv', 'text/csv')
			attach_file "import_file", 'spec/fixtures/files/location_without_error.csv'
			click_button "Upload"
			expect(page).to have_selector('div.alert.alert-success')

		end

		it "cannot import locations with invalid longitude" do
			attach_file "import_file", 'spec/fixtures/files/location_with_long_error.csv'
			click_button "Upload"
				
			expect(page).to have_selector('div#error_explanation')
		end

		it "cannot import locations with invalid latitude" do

			attach_file "import_file", 'spec/fixtures/files/location_with_lat_error.csv'
			click_button "Upload"
				
			expect(page).to have_selector('div#error_explanation')

		end

	end

end